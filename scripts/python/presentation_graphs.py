import scipy.io
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import sys
import statsmodels.api as sm 

cansat_file = sys.argv[1] 
x_axis = sys.argv[2].lower()
y_axis = sys.argv[3].lower()

cansat_data = pd.read_csv(cansat_file)

x = cansat_data[x_axis]
y = cansat_data[y_axis]

plt.style.use('ggplot')
fig, ax = plt.subplots(figsize=(10, 6))

x, y = np.array(x), np.array(y)

if len(sys.argv) >= 5:
    if sys.argv[4] == "regression":
        if x_axis == "timestamp":
            x = x / 1e6
        x_model = sm.add_constant(x)
        model = sm.OLS(y, x_model)
        results = model.fit()
        intercept = results.params[0]
        slope = results.params[1]
        r_squared = results.rsquared
        print(f'{len(x)} {len(y)}')
        ax.plot(x, y, color='red')

        plt.rcParams["font.family"] = "sans-serif"
        plt.rcParams["font.sans-serif"] = "Helvetica"

        ax.set_title(f'{y_axis.capitalize()} vs. {x_axis.capitalize()}', fontsize=14, fontweight='bold')
        match x_axis:
            case "pressure":
                ax.set_xlabel(f'Pressure (Pa)', fontsize=12)
            case "temperature":
                ax.set_xlabel(f'Temperature (ºC)', fontsize=12)
            case "humidity":
                ax.set_xlabel(f'Relative Humidity (%)', fontsize=12)
            case "altitude":
                ax.set_xlabel('Altitude (m)', fontsize=12)
            case "timestamp":
                ax.set_xlabel('Time (s)', fontsize=12)
            case _:
                ax.set_xlabel("")
        match y_axis:
            case "pressure":
                ax.set_ylabel(f'Pressure (Pa)', fontsize=12)
            case "temperature":
                ax.set_ylabel(f'Temperature (ºC)', fontsize=12)
            case "humidity":
                ax.set_ylabel(f'Relative Humidity (%)', fontsize=12)
            case "altitude":
                ax.set_ylabel('Altitude (m)', fontsize=12)
            case _:
                ax.set_ylabel("")

        ax.set_facecolor("#fffde9")
        fig.patch.set_facecolor("#fffde9")
        ax.plot(x, (slope * x) + intercept, color='#031020', linewidth=2, label='OLS Regression Line')
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
    if x_axis == "timestamp":
        x = x / 1e6
    ax.plot(x, y, color='red', linewidth=2)
    plt.rcParams["font.family"] = "sans-serif"
    plt.rcParams["font.sans-serif"] = "Helvetica"

    ax.set_title(f'{y_axis.capitalize()} vs. {x_axis.capitalize()}', fontsize=14, fontweight='bold')
    match x_axis:
        case "pressure":
            ax.set_xlabel(f'Pressure (Pa)', fontsize=12)
        case "temperature":
            ax.set_xlabel(f'Temperature (ºC)', fontsize=12)
        case "humidity":
            ax.set_xlabel(f'Relative Humidity (%)', fontsize=12)
        case "altitude":
            ax.set_xlabel('Altitude (m)', fontsize=12)
        case "timestamp":
            ax.set_xlabel('Time (s)', fontsize=12)
        case _:
            ax.set_xlabel("")
    match y_axis:
        case "pressure":
            ax.set_ylabel(f'Pressure (Pa)', fontsize=12)
        case "temperature":
            ax.set_ylabel(f'Temperature (ºC)', fontsize=12)
        case "humidity":
            ax.set_ylabel(f'Relative Humidity (%)', fontsize=12)
        case "altitude":
            ax.set_ylabel('Altitude (m)', fontsize=12)
        case _:
            ax.set_ylabel("")

    ax.set_facecolor("#fffde9")
    fig.patch.set_facecolor("#fffde9")

    plt.grid(visible=True, color="#d8d7c4")
    ax.legend()
    plt.tight_layout()
    plt.show()


