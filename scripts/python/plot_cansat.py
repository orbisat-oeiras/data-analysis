import scipy.io
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import sys
import statsmodels.api as sm 

mat_data = scipy.io.loadmat('python/data/cansat_export.mat')

if len(sys.argv) >= 3:
    cansat_file = sys.argv[1]
    analyzed_variable = sys.argv[2].lower()
    regression_type = sys.argv[3]
    cansat_data = pd.read_csv(cansat_file)

    time_col = 'timestamp'

    cansat_data['timestamp'] = cansat_data['timestamp'] / 1e3

    cansat_data = cansat_data.sort_values(by=time_col)

    v = mat_data['speeds'].flatten()
    delta_v = mat_data['delta_v'][0][0]
    timestamp = mat_data['timestamps'].flatten()
    audio_df = pd.DataFrame({
        time_col: timestamp, 
        'speeds': v,
        'delta_v': delta_v
    })
    audio_df = audio_df.sort_values(by=time_col)

    min_cansat_time = cansat_data[time_col].min()
    audio_df = audio_df[audio_df[time_col] >= min_cansat_time]

    merged_df = pd.merge_asof(audio_df, cansat_data, on=time_col, direction='nearest')


    v_synced = merged_df['speeds'].values
    delta_v_synced = merged_df['delta_v'].values
    x_raw = merged_df[analyzed_variable].values

    X_model = sm.add_constant(x_raw)

    if regression_type == "wls":
        weights = 1.0 / (delta_v_synced ** 2)
        model = sm.WLS(v_synced, X_model, weights=weights)
    else:
        model = sm.OLS(v_synced, X_model)

    results = model.fit()   

    intercept = results.params[0]
    slope = results.params[1]
    r_squared = results.rsquared

    x_line = np.linspace(x_raw.min(), x_raw.max(), 100)
    y_line = slope * x_line + intercept

    plt.style.use('ggplot')
    fig, ax = plt.subplots(figsize=(10, 6))

    ax.scatter(x_raw, v_synced, color="#231f20")

    ax.plot(x_line, y_line, color='red', linewidth=2, label=f'{regression_type.upper()} Regression Line')

    plt.rcParams["font.family"] = "sans-serif"
    plt.rcParams["font.sans-serif"] = "Helvetica"

    ax.set_title(f'Speed of Sound vs. {analyzed_variable.capitalize()}', fontsize=14, fontweight='bold')
    ax.set_xlabel(f'{analyzed_variable.capitalize()}', fontsize=12)
    ax.set_ylabel('Speed of Sound (m/s)', fontsize=12)
    ax.set_facecolor("#fffde9")
    fig.patch.set_facecolor("#fffde9")
    stats_text = (
        f"Equation: $v = {slope:.4f}x + {intercept:.2f}$\n"
        f"$R^2 = {r_squared:.4f}$"
    )
    props = dict(boxstyle='round', facecolor='white', alpha=0.9, edgecolor='gray')
    ax.text(0.05, 0.95, stats_text, transform=ax.transAxes, fontsize=11,
            verticalalignment='top', bbox=props)

    plt.grid(visible=True, color="#d8d7c4")
    ax.legend()
    plt.tight_layout()
    plt.show()


else:
    type = sys.argv[1]

    if type == "single":
        f = mat_data['f'].flatten()

        spectrum = mat_data['spectrum'].flatten()

        v = mat_data['v'][0][0]
        delta_v = mat_data['delta_v'][0][0]

        peak_idx = np.argmax(spectrum)
        peak_f = f[peak_idx]
        peak_amp = spectrum[peak_idx]

        plt.style.use('ggplot') 
        fig = plt.figure(figsize=(11, 8))

        plt.plot(f, spectrum, color='#231f20', linewidth=1.5, label='Frequency Spectrum')

        plt.plot(peak_f, peak_amp, 'o', markersize=8, color='#dd5928', label=f'Peak: {peak_f:.2f} Hz')
        ax = plt.gca()
        ax.set_facecolor("#fffde9")
        fig.patch.set_facecolor("#fffde9")
        
        plt.rc('font', size=12)
        plt.xticks(fontsize = 12)
        plt.yticks(fontsize = 12)

        plt.title('CanSat Resonance Spectrum', fontsize=16, fontweight='bold')
        plt.xlabel('Frequency (Hz)', fontsize=16)
        plt.ylabel('Amplitude (a.u.)', fontsize=16)
        plt.xlim(2550, 2670)
        plt.rcParams["font.family"] = "sans-serif"
        plt.rcParams["font.sans-serif"] = "Helvetica"

        text_str = f"$v = {v:.2f} \\pm {delta_v:.2f}$ m/s"
        plt.annotate(text_str, xy=(0.75, 0.80), xycoords='axes fraction',
                    bbox=dict(boxstyle="round,pad=0.5", fc="white", ec="gray", alpha=0.9),
                    fontsize=14)
        plt.grid(visible=True, color="#d8d7c4")
        plt.legend(loc="upper right", fontsize=15)
        plt.tight_layout()

        plt.show()
    else:
        v = mat_data['speeds'].flatten()
        timestamps = mat_data['timestamps'].flatten()

        plt.style.use('ggplot') 
        fig = plt.figure(figsize=(10, 6))

        plt.plot(timestamps, v, color='#231f20', linewidth=1.5, label='Speed of Sound')

        ax = plt.gca()
        ax.set_facecolor("#fffde9")
        fig.patch.set_facecolor("#fffde9")

        plt.title('CanSat Speed of Sound', fontsize=14, fontweight='bold')
        plt.xlabel('Time (ms)', fontsize=12)
        plt.ylabel('Speed of Sound (m/s)', fontsize=12)
        plt.rcParams["font.family"] = "sans-serif"
        plt.rcParams["font.sans-serif"] = "Helvetica"

        plt.grid(visible=True, color="#d8d7c4")
        plt.legend(loc="upper right")
        plt.tight_layout()

        plt.show()