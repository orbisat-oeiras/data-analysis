# OrbiSat 2026 Data Analysis Scripts

The main script file to be used is [analyze_data.m](https://github.com/orbisat-oeiras/data-analysis/blob/restructure/scripts/analyze_data.m).

## Requirements

- Python 3
  - scipy.io
  - matplotlib
  - numpy
  - pandas
  - statsmodels.api
- Create `audio` folder on `scripts/`
- Create `data` folder on `scripts/python/`
- Check the Python PATH (whether `python3` or `python`), and change path on [analyze_data.m](https://github.com/orbisat-oeiras/data-analysis/blob/restructure/scripts/analyze_data.m)

## Usage

### Required Parameters

- `datatype`
  - `single` - indicates a single data source is being used, e.g. calculating the speed of sound for only one audio file, with requirement of the `fname` argument.
  - `series` - indicates a series of audio files being analyzed, with requirement of the `bootcount` argument
- `L` - length of the tube, in meters

### Optional Parameters

- `bootcount` - to be used in combination with `series`. Every sequence of recorded audio files will have an associated bootcount number, representing how many times the CanSat has been booted.

- `fname` - to be used in combination with `single`. Indicates the location of the audio recording.

- `cansat_data` - to be used in combination with `series`. Indicates the location of the groundstation .csv data.

- `variable` - to be used in combination with `cansat_data` and `fig_py`, indicating the desired CanSat variable to be the x-axis on the speed of sound graph.

- `original` - location of original audio file. Implementation for this is not tested, and shall not be used before proper testing.

- `method` - `direct` or `correlation` - defaults to `direct`. `correlation` is needed when cross-correlation with the original audio file is desired.

- `regression_type` - OLS (Ordinary Least Squares) or WLS (Weighted Least Squares).

### Switches

- `disp` - prints out the computed speed of sound.

- `fig` - display the figure using GNU Octave.

- `fig_py` - display the figure using Python.

- `csv` - exports the analysed data to a csv file

## Example Usage

On the Octave shell, to analyze a series of audio files, with a tube of length L with bootcount 1, to graph the speed of sound in function of time with Python:

```shell
octave:1> analyze_data("series", L, "bootcount", "1", "fig_py")
```

to analyze a series of audio files, with a tube of length L, bootcount 1, and correlate the temperature from a .csv file with WLS, and display the data with Python:

```shell
octave:1> analyze_data("series", L, "bootcount", "1", "cansat_data", "CANSAT_FILE_PATH", "variable", "temperature", "regression_type", "wls", "fig_py")
```

get the resonance frequency of an audio file and display with Python:

```shell
octave:1> analyze_data("single", L, "fname", "AUDIO_FILE", "fig_py")
```
