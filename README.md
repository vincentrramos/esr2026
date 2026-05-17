# Replication Package for Ramos and Berrington (2026) European Sociological Review

**Paper:** *[Labour market insecurity and parental co-residence in the United Kingdom: heterogeneities by parental class and age](https://doi.org/10.1093/esr/jcaf058)*  
**Authors:** Vincent Jerald Ramos and Ann Berrington  
**Date:** Janaury 2026

## Contents

```text
.
├── README_replication.md
├── 1_lfswrangling.do       # Builds derived analytical datasets from raw LFS/QLFS files
├── 2_descriptives.do       # Produces descriptive table info
├── 3_lfsanalysis.do        # Produces regression figures
├── data/
│   └── QLFS_2014_2023_Q3_all/   # User-created folder for raw UKDS files; not included
└── output/
    ├── tables/             # Derived .dta files are currently written here
    └── figures/            # Figures 
```

Raw data are **not** included in this replication package because they must be accessed through UK Data Service under the relevant access conditions.

## Data availability and access

The data can be accessed via UK Data Service:

<https://datacatalogue.ukdataservice.ac.uk/series/series/2000026>

Series: **Labour Force Survey**  
UKDS series number: **2000026**  
DOI: **10.5255/UKDA-Series-2000026**

Users must register with UK Data Service, accept the applicable End User Licence or other access terms, and comply with all redistribution restrictions. Do not redistribute the raw data or any derived data as this would breach UK Data Service terms.

The submitted wrangling script expects the following Stata data files in:

```text
<project-folder>/data/QLFS_2014_2023_Q3_all/
```

Required files as currently hard-coded in `1_lfswrangling.do`:

```text
lfsp_js16_eul_pwt18.dta
lfsp_js17_eul_pwt18.dta
lfsp_js18_eul_pwt18.dta
lfsp_js19_eul_pwt18.dta
lfsp_js21_eul_pwt22.dta
lfsp_js22_eul_pwt23.dta
lfsp_js23_eul_pwt24.dta
lfsp_js24_eul_pwt24.dta
```

The scripts append these files, construct variables, and then create three derived datasets, of which the main one used for analysis is:

```text
output/tables/individual_longer.dta             # Economically active ages 18-34, excluding full-time students
```

## Software requirements

The scripts are written for **Stata**. Stata 17 or later is recommended because `2_descriptives.do` uses the `table`/`collect` framework.

Community-contributed commands used by the scripts:

```stata
ssc install estout      // provides eststo and esttab
ssc install coefplot
ssc install mplotoffset
```

For full reproducibility, record the Stata version and installed package versions used to produce the final results, for example by running:

```stata
about
which esttab
which eststo
which coefplot
which mplotoffset
```

## How to run the replication code

1. Download the required raw data files from UK Data Service.
2. Create the folder structure shown above.
3. Place the raw `.dta` files in:

   ```text
   <project-folder>/data/QLFS_2014_2023_Q3_all/
   ```

4. In each `.do` file, edit this line so that it points to the local project folder:

   ```stata
   global PROJDIR "[PATH_TO_PROJECT_FOLDER]"
   ```

   Example on Windows:

   ```stata
   global PROJDIR "C:/Users/yourname/project-folder"
   ```

5. Run the scripts in this order:

   ```stata
   do 1_lfswrangling.do
   do 2_descriptives.do
   do 3_lfsanalysis.do
   ```

## Expected outputs

`1_lfswrangling.do` creates derived datasets:

```text
output/tables/individual.dta
output/tables/individual_longer.dta
output/tables/individual_longer_wstudents.dta
```

`2_descriptives.do` creates descriptive outputs:


`3_lfsanalysis.do` creates figure files:

```text
output/figures/figure4_age18_h1_precarityall_full.png
output/figures/figure4_age18_h1_precarityall_full.eps
output/figures/figure5_age18_h3_precarity_age_ame_alt.png
output/figures/figure5_age18_h3_precarity_age_ame_alt.eps
output/figures/figure6_age18_h4_precarity_pclass_ame_alt.png
output/figures/figure6_age18_h4_precarity_pclass_ame_alt.eps
output/figures/figure7_age18_h5b_precarity_pclass_age_ame_alt2.png
output/figures/figure7_age18_h5b_precarity_pclass_age_ame_alt2.eps
```

## Data acknowledgement:

Users should cite the UK Data Service / Office for National Statistics data according to the citation provided in the UKDS catalogue for the relevant files and series. A suggested series-level reference is:

Office for National Statistics. *Labour Force Survey*. UK Data Service Series 2000026. DOI: 10.5255/UKDA-Series-2000026.

## License and Citation

The replication code in this repository is released under the MIT License. See the `LICENSE` file for details.

The license applies only to the code and documentation in this repository. The underlying survey data are not redistributed here and remain subject to the access conditions and terms of use of the original data provider.

Please cite the associated article when using this replication package:

Ramos, V. J., & Berrington, A. (2026). Labour market insecurity and parental co-residence in the United Kingdom: heterogeneities by parental class and age. European Sociological Review, jcaf058.


For questions about this replication package, contact the corresponding author of the paper.

