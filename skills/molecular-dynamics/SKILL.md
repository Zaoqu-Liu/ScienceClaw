---
name: molecular-dynamics
description: Autonomous molecular dynamics simulation pipeline inspired by DynaMate (2026). Designs, executes, and analyzes complete MD workflows for protein and protein-ligand systems. Covers structure retrieval, system preparation, minimization, equilibration, production, and trajectory analysis (RMSD, RMSF, hydrogen bonds, binding free energy). Uses OpenMM as the primary engine with AmberTools for preparation. Self-correcting — detects and fixes common simulation failures. Use when users ask for MD simulations, protein stability analysis, binding free energy calculations, or "跑个分子动力学模拟". Requires OpenMM and optionally AmberTools.
---

# Molecular Dynamics Simulation Pipeline

Autonomous molecular dynamics simulation from structure to analysis. Inspired by DynaMate's three-module architecture: Experiment Planner → Simulation Performer → Result Analyzer.

## When to Use

- "帮我跑个 MD 模拟" or "molecular dynamics simulation for X"
- "计算 X 和 Y 的结合自由能" or "binding free energy"
- "这个蛋白稳定吗" or "protein stability analysis"
- "蛋白-配体相互作用模拟"
- User provides a PDB ID, UniProt ID, or protein structure file

## Prerequisites Check

Before starting any simulation, verify the environment:

```bash
bash: python3 << 'PYEOF'
import sys

checks = {"openmm": False, "ambertools": False, "mdtraj": False, "pdbfixer": False, "nglview": False}

try:
    import openmm
    checks["openmm"] = True
    print(f"✅ OpenMM {openmm.__version__}")
except ImportError:
    print("❌ OpenMM not installed")
    print("   Install: conda install -c conda-forge openmm")

try:
    import parmed
    checks["ambertools"] = True
    print("✅ AmberTools (via parmed)")
except ImportError:
    print("⚠️  AmberTools not installed (optional, for ligand parameterization)")
    print("   Install: conda install -c conda-forge ambertools")

try:
    import mdtraj
    checks["mdtraj"] = True
    print(f"✅ MDTraj {mdtraj.__version__}")
except ImportError:
    print("❌ MDTraj not installed (needed for analysis)")
    print("   Install: pip install mdtraj")

try:
    import pdbfixer
    checks["pdbfixer"] = True
    print("✅ PDBFixer")
except ImportError:
    print("❌ PDBFixer not installed (needed for structure preparation)")
    print("   Install: conda install -c conda-forge pdbfixer")

if not checks["openmm"]:
    print("\n⛔ Cannot run MD simulations without OpenMM.")
    print("Recommend: conda create -n md python=3.11 openmm pdbfixer mdtraj parmed -c conda-forge")
    sys.exit(1)

print("\n✅ Environment ready for MD simulations")
PYEOF
```

If OpenMM is not available, report clearly and do not attempt the simulation.

---

## Pipeline

### Step 1: Structure Retrieval

Fetch the protein structure:

```bash
# From PDB
curl -s "https://files.rcsb.org/download/PDBID.pdb" -o structure.pdb

# From AlphaFold (if no experimental structure)
curl -s "https://alphafold.ebi.ac.uk/files/AF-UNIPROT_ID-F1-model_v4.pdb" -o structure.pdb
```

If user provides a gene name, resolve to UniProt ID first:
```bash
curl -s "https://rest.uniprot.org/uniprotkb/search?query=gene_exact:GENE+AND+organism_id:9606&format=json&size=1" | \
python3 -c "import sys,json; d=json.load(sys.stdin); print(d['results'][0]['primaryAccession'])"
```

### Step 2: Structure Preparation

Fix common PDB issues and prepare the system:

```python
from pdbfixer import PDBFixer
from openmm.app import PDBFile

fixer = PDBFixer(filename='structure.pdb')
fixer.findMissingResidues()
fixer.findMissingAtoms()
fixer.addMissingAtoms()
fixer.addMissingHydrogens(7.4)  # pH 7.4

# Remove heterogens except ligand of interest (if any)
fixer.removeHeterogens(keepWater=False)

PDBFile.writeFile(fixer.topology, fixer.positions, open('prepared.pdb', 'w'))
print(f"Prepared structure: {fixer.topology.getNumAtoms()} atoms, {fixer.topology.getNumResidues()} residues")
```

### Step 3: System Setup

```python
from openmm.app import *
from openmm import *
from openmm.unit import *

pdb = PDBFile('prepared.pdb')
forcefield = ForceField('amber14-all.xml', 'amber14/tip3pfb.xml')

modeller = Modeller(pdb.topology, pdb.positions)
modeller.addSolvent(forcefield, model='tip3p', padding=1.0*nanometers,
                    ionicStrength=0.15*molar)

system = forcefield.createSystem(modeller.topology,
    nonbondedMethod=PME,
    nonbondedCutoff=1.0*nanometers,
    constraints=HBonds)

print(f"System: {modeller.topology.getNumAtoms()} atoms (protein + water + ions)")
```

### Step 4: Energy Minimization

```python
integrator = LangevinMiddleIntegrator(300*kelvin, 1/picosecond, 0.004*picoseconds)
simulation = Simulation(modeller.topology, system, integrator)
simulation.context.setPositions(modeller.positions)

# Minimize
print(f"Initial PE: {simulation.context.getState(getEnergy=True).getPotentialEnergy()}")
simulation.minimizeEnergy(maxIterations=1000)
pe = simulation.context.getState(getEnergy=True).getPotentialEnergy()
print(f"Minimized PE: {pe}")

# Self-correction: if PE is positive or very high, something is wrong
if pe._value > 0:
    print("⚠️  Potential energy is positive — possible steric clash")
    print("   Attempting additional minimization with tolerance=100...")
    simulation.minimizeEnergy(maxIterations=5000, tolerance=100*kilojoules_per_mole)
    pe = simulation.context.getState(getEnergy=True).getPotentialEnergy()
    print(f"Re-minimized PE: {pe}")
```

### Step 5: Equilibration

```python
# NVT equilibration (100 ps)
simulation.context.setVelocitiesToTemperature(300*kelvin)
simulation.reporters.append(StateDataReporter('nvt_log.csv', 1000,
    step=True, temperature=True, potentialEnergy=True))
simulation.step(25000)  # 100 ps at 4 fs/step
print("NVT equilibration complete (100 ps)")

# NPT equilibration (100 ps)
system.addForce(MonteCarloBarostat(1*bar, 300*kelvin))
simulation.context.reinitialize(preserveState=True)
simulation.reporters.append(StateDataReporter('npt_log.csv', 1000,
    step=True, density=True, potentialEnergy=True))
simulation.step(25000)
print("NPT equilibration complete (100 ps)")
```

### Step 6: Production Run

```python
simulation.reporters.clear()
simulation.reporters.append(DCDReporter('trajectory.dcd', 5000))  # Save every 20 ps
simulation.reporters.append(StateDataReporter('production_log.csv', 5000,
    step=True, time=True, potentialEnergy=True, temperature=True, density=True))

# Default: 10 ns production (adjust based on system size)
n_steps = 2500000  # 10 ns at 4 fs/step
print(f"Starting production run: 10 ns ({n_steps} steps)")
simulation.step(n_steps)
print("Production run complete")

# Save final state
simulation.saveState('final_state.xml')
PDBFile.writeFile(simulation.topology, simulation.context.getState(getPositions=True).getPositions(),
                  open('final_frame.pdb', 'w'))
```

### Step 7: Trajectory Analysis

```python
import mdtraj as md
import matplotlib.pyplot as plt
import numpy as np

traj = md.load('trajectory.dcd', top='prepared.pdb')
print(f"Trajectory: {traj.n_frames} frames, {traj.n_atoms} atoms, {traj.time[-1]/1000:.1f} ns")

fig_dir = "figures"
os.makedirs(fig_dir, exist_ok=True)

# RMSD
rmsd = md.rmsd(traj, traj, 0, atom_indices=traj.topology.select('protein and name CA'))
plt.figure(figsize=(8,4), dpi=300)
plt.plot(traj.time/1000, rmsd*10, linewidth=0.8)
plt.xlabel('Time (ns)'); plt.ylabel('RMSD (Å)')
plt.title('Backbone RMSD'); plt.tight_layout()
plt.savefig(f'{fig_dir}/rmsd.png', dpi=300)
print(f"Mean RMSD: {np.mean(rmsd)*10:.2f} ± {np.std(rmsd)*10:.2f} Å")

# RMSF
rmsf = md.rmsf(traj, traj, atom_indices=traj.topology.select('protein and name CA'))
plt.figure(figsize=(10,4), dpi=300)
plt.plot(range(len(rmsf)), rmsf*10, linewidth=0.8)
plt.xlabel('Residue Index'); plt.ylabel('RMSF (Å)')
plt.title('Per-Residue RMSF'); plt.tight_layout()
plt.savefig(f'{fig_dir}/rmsf.png', dpi=300)

# Radius of gyration
rg = md.compute_rg(traj)
print(f"Radius of gyration: {np.mean(rg)*10:.2f} ± {np.std(rg)*10:.2f} Å")

# Hydrogen bonds
hbonds = md.baker_hubbard(traj, freq=0.3)
print(f"Persistent hydrogen bonds (>30% occupancy): {len(hbonds)}")
```

---

## Self-Correction Protocol

| Error | Detection | Fix |
|-------|-----------|-----|
| Steric clashes | PE > 0 after minimization | Additional minimization with relaxed tolerance |
| Temperature instability | T deviates >50K from target | Reduce timestep to 2 fs, re-equilibrate |
| Box collapse | Density > 1.2 g/cm³ | Increase box padding, re-solvate |
| NaN in coordinates | Simulation crashes | Reduce timestep, check topology for bad parameters |
| Missing residues | PDBFixer reports gaps | Use PDBFixer to model missing loops |

After each step, check for errors before proceeding. Maximum 3 retry attempts per step.

---

## Output Report Structure

```markdown
# Molecular Dynamics Simulation Report: [PROTEIN]

## System Summary
- PDB ID: [ID] / AlphaFold model: [AF-ID]
- Protein: [Name], [N] residues, [N] atoms
- Solvation: TIP3P water, 0.15 M NaCl, [N] total atoms
- Force field: Amber14

## Simulation Parameters
- Temperature: 300 K (Langevin thermostat, γ = 1/ps)
- Pressure: 1 bar (Monte Carlo barostat)
- Timestep: 4 fs
- Cutoff: 10 Å (PME electrostatics)
- Production: [X] ns

## Results
- RMSD: [mean ± std] Å (converged after [X] ns)
- RMSF: [highlight flexible regions]
- Rg: [mean ± std] Å
- Persistent H-bonds: [N] (>30% occupancy)

## Structural Stability Assessment
[Interpretation of RMSD convergence, flexible regions, overall stability]

## Figures
- figures/rmsd.png — Backbone RMSD over time
- figures/rmsf.png — Per-residue flexibility
```

---

## Limitations

- GPU strongly recommended for production runs (CPU is 10-100x slower)
- Default 10 ns may be insufficient for large conformational changes
- Ligand parameterization requires AmberTools and GAFF force field
- MM/PBSA calculations are approximate and should be validated experimentally
- This skill does not replace expert computational chemistry judgment for publication-grade simulations
