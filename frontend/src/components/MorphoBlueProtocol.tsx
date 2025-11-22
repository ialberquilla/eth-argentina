"use client";

import { useEffect, useRef, useState } from "react";
import Chart from "chart.js/auto";

export const MorphoBlueProtocol = () => {
  const chartRef = useRef<HTMLCanvasElement>(null);
  const chartInstanceRef = useRef<Chart | null>(null);
  const [activeTab, setActiveTab] = useState(0);

  useEffect(() => {
    if (!chartRef.current) return;

    const ctx = chartRef.current.getContext("2d");
    if (!ctx) return;

    // Clean up previous chart instance
    if (chartInstanceRef.current) {
      chartInstanceRef.current.destroy();
    }

    // Generate realistic historical data (90 days)
    const days = 90;
    const labels: string[] = [];
    const apyData: number[] = [];
    const tvlData: number[] = [];

    for (let i = days; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      labels.push(
        date.toLocaleDateString("en-US", { month: "short", day: "numeric" })
      );

      // APY fluctuating around 8.5% with some volatility
      const baseAPY = 8.5;
      const noise = (Math.random() - 0.5) * 0.8;
      const trend = Math.sin(i / 15) * 0.5;
      apyData.push(baseAPY + noise + trend);

      // TVL growing from 550M to 650M
      const baseTVL = 550 + (100 * (days - i)) / days;
      const tvlNoise = (Math.random() - 0.5) * 20;
      tvlData.push(baseTVL + tvlNoise);
    }

    chartInstanceRef.current = new Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: [
          {
            label: "APY (%)",
            data: apyData,
            borderColor: "#3b82f6",
            backgroundColor: "rgba(59, 130, 246, 0.1)",
            borderWidth: 2,
            fill: false,
            tension: 0.4,
            pointRadius: 0,
            pointHoverRadius: 4,
            yAxisID: "y",
          },
          {
            label: "TVL ($M)",
            data: tvlData,
            borderColor: "#8b5cf6",
            backgroundColor: "rgba(139, 92, 246, 0.15)",
            borderWidth: 2,
            fill: true,
            tension: 0.4,
            pointRadius: 0,
            pointHoverRadius: 4,
            yAxisID: "y1",
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          mode: "index",
          intersect: false,
        },
        plugins: {
          legend: {
            display: false,
          },
          tooltip: {
            backgroundColor: "#1e293b",
            titleColor: "#e4e4e7",
            bodyColor: "#94a3b8",
            borderColor: "#334155",
            borderWidth: 1,
            padding: 12,
            displayColors: true,
            callbacks: {
              label: function (context) {
                let label = context.dataset.label || "";
                if (label) {
                  label += ": ";
                }
                if (context.parsed.y !== null) {
                  if (context.datasetIndex === 0) {
                    label += context.parsed.y.toFixed(2) + "%";
                  } else {
                    label += "$" + context.parsed.y.toFixed(0) + "M";
                  }
                }
                return label;
              },
            },
          },
        },
        scales: {
          x: {
            grid: {
              display: false,
            },
            ticks: {
              color: "#64748b",
              maxTicksLimit: 10,
            },
          },
          y: {
            type: "linear",
            display: true,
            position: "left",
            grid: {
              color: "#1e293b",
            },
            ticks: {
              color: "#3b82f6",
              callback: function (value) {
                return (value as number).toFixed(1) + "%";
              },
            },
            title: {
              display: true,
              text: "APY",
              color: "#3b82f6",
              font: {
                size: 12,
                weight: 600,
              },
            },
          },
          y1: {
            type: "linear",
            display: true,
            position: "right",
            grid: {
              drawOnChartArea: false,
            },
            ticks: {
              color: "#8b5cf6",
              callback: function (value) {
                return "$" + (value as number).toFixed(0) + "M";
              },
            },
            title: {
              display: true,
              text: "TVL",
              color: "#8b5cf6",
              font: {
                size: 12,
                weight: 600,
              },
            },
          },
        },
      },
    });

    return () => {
      if (chartInstanceRef.current) {
        chartInstanceRef.current.destroy();
      }
    };
  }, []);

  return (
    <div className="max-w-[1400px] mx-auto">
      <style jsx>{`
        .modal-overlay {
          background: rgba(10, 14, 39, 0.95);
          border-radius: 16px;
          border: 1px solid #1e293b;
          overflow: hidden;
          box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }

        .modal-header {
          background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
          padding: 24px 32px;
          border-bottom: 1px solid #334155;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .header-left {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .protocol-icon {
          width: 48px;
          height: 48px;
          background: linear-gradient(135deg, #3b82f6, #8b5cf6);
          border-radius: 12px;
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: bold;
          font-size: 20px;
        }

        .header-info h2 {
          font-size: 24px;
          font-weight: 600;
          margin-bottom: 4px;
        }

        .header-meta {
          font-size: 14px;
          color: #94a3b8;
          display: flex;
          gap: 16px;
          align-items: center;
        }

        .badge {
          padding: 4px 10px;
          border-radius: 6px;
          font-size: 12px;
          font-weight: 500;
        }

        .badge-medium {
          background: #78350f;
          color: #fbbf24;
        }

        .close-btn {
          background: #1e293b;
          border: 1px solid #334155;
          color: #94a3b8;
          width: 36px;
          height: 36px;
          border-radius: 8px;
          cursor: pointer;
          font-size: 18px;
          transition: all 0.2s;
        }

        .close-btn:hover {
          background: #334155;
          color: #e4e4e7;
        }

        .modal-content {
          display: grid;
          grid-template-columns: 60% 40%;
          min-height: 600px;
        }

        .chart-section {
          padding: 32px;
          background: #0f172a;
          border-right: 1px solid #1e293b;
        }

        .chart-tabs {
          display: flex;
          gap: 8px;
          margin-bottom: 24px;
          border-bottom: 1px solid #1e293b;
          padding-bottom: 8px;
        }

        .tab {
          padding: 8px 16px;
          background: transparent;
          border: none;
          color: #64748b;
          cursor: pointer;
          font-size: 14px;
          font-weight: 500;
          border-radius: 6px;
          transition: all 0.2s;
          position: relative;
        }

        .tab:hover {
          color: #94a3b8;
          background: #1e293b;
        }

        .tab.active {
          color: #3b82f6;
          background: #1e3a5f;
        }

        .tab.active::after {
          content: "";
          position: absolute;
          bottom: -9px;
          left: 0;
          right: 0;
          height: 2px;
          background: #3b82f6;
        }

        .chart-container {
          position: relative;
          height: 400px;
        }

        .card-section {
          padding: 32px;
          background: #0a0e27;
          overflow-y: auto;
          max-height: 600px;
        }

        .metric-group {
          margin-bottom: 28px;
          animation: fadeIn 0.4s ease-out;
        }

        .metric-group:nth-child(2) {
          animation-delay: 0.1s;
        }
        .metric-group:nth-child(3) {
          animation-delay: 0.2s;
        }
        .metric-group:nth-child(4) {
          animation-delay: 0.3s;
        }
        .metric-group:nth-child(5) {
          animation-delay: 0.4s;
        }

        @keyframes fadeIn {
          from {
            opacity: 0;
            transform: translateY(10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .metric-group-title {
          font-size: 13px;
          font-weight: 600;
          color: #64748b;
          text-transform: uppercase;
          letter-spacing: 0.5px;
          margin-bottom: 16px;
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .status-icon {
          font-size: 16px;
        }

        .metric-row {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 10px 0;
          border-bottom: 1px solid #1e293b;
        }

        .metric-row:last-child {
          border-bottom: none;
        }

        .metric-label {
          font-size: 14px;
          color: #94a3b8;
        }

        .metric-value {
          font-size: 14px;
          font-weight: 600;
          color: #e4e4e7;
          text-align: right;
        }

        .metric-value.positive {
          color: #6ee7b7;
        }

        .metric-value.negative {
          color: #fca5a5;
        }

        .metric-value.warning {
          color: #fbbf24;
        }

        .progress-bar {
          width: 100%;
          height: 6px;
          background: #1e293b;
          border-radius: 3px;
          overflow: hidden;
          margin-top: 8px;
        }

        .progress-fill {
          height: 100%;
          background: linear-gradient(90deg, #3b82f6, #8b5cf6);
          border-radius: 3px;
          transition: width 0.3s ease;
        }

        .yield-breakdown {
          display: flex;
          flex-direction: column;
          gap: 12px;
          margin-top: 12px;
        }

        .yield-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 10px 14px;
          background: #0f172a;
          border-radius: 8px;
          border-left: 3px solid transparent;
        }

        .yield-item.sustainable {
          border-left-color: #6ee7b7;
        }
        .yield-item.temporary {
          border-left-color: #fbbf24;
        }

        .yield-label {
          font-size: 13px;
          color: #94a3b8;
        }

        .yield-value {
          font-size: 14px;
          font-weight: 600;
          color: #e4e4e7;
        }

        .cta-button {
          width: 100%;
          padding: 14px;
          background: linear-gradient(135deg, #3b82f6, #8b5cf6);
          border: none;
          border-radius: 10px;
          color: white;
          font-weight: 600;
          font-size: 15px;
          cursor: pointer;
          margin-top: 24px;
          transition: all 0.3s;
        }

        .cta-button:hover {
          transform: translateY(-2px);
          box-shadow: 0 10px 25px -5px rgba(59, 130, 246, 0.5);
        }

        .risk-score {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 16px;
          background: #0f172a;
          border-radius: 10px;
          margin-top: 12px;
        }

        .risk-score-number {
          font-size: 32px;
          font-weight: 700;
          background: linear-gradient(135deg, #6ee7b7, #3b82f6);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
        }

        .risk-score-label {
          font-size: 13px;
          color: #64748b;
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .info-tooltip {
          display: inline-block;
          width: 16px;
          height: 16px;
          background: #1e293b;
          border-radius: 50%;
          text-align: center;
          line-height: 16px;
          font-size: 11px;
          color: #64748b;
          cursor: help;
          margin-left: 4px;
        }

        .chart-legend {
          display: flex;
          justify-content: center;
          gap: 24px;
          margin-top: 16px;
          font-size: 13px;
        }

        .legend-item {
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .legend-color {
          width: 12px;
          height: 12px;
          border-radius: 2px;
        }
      `}</style>

      <div className="modal-overlay">
        <div className="modal-header">
          <div className="header-left">
            <div className="protocol-icon">MB</div>
            <div className="header-info">
              <h2>Morpho Blue</h2>
              <div className="header-meta">
                <span>Ethereum • USDC</span>
                <span className="badge badge-medium">Medium Risk</span>
                <span style={{ color: "#6ee7b7" }}>●</span>
                <span>Active Monitoring</span>
              </div>
            </div>
          </div>
          <button className="close-btn">✕</button>
        </div>

        <div className="modal-content">
          {/* CHART SECTION */}
          <div className="chart-section">
            <div className="chart-tabs">
              <button
                className={`tab ${activeTab === 0 ? "active" : ""}`}
                onClick={() => setActiveTab(0)}
              >
                APY & TVL History
              </button>
              <button
                className={`tab ${activeTab === 1 ? "active" : ""}`}
                onClick={() => setActiveTab(1)}
              >
                Yield Composition
              </button>
              <button
                className={`tab ${activeTab === 2 ? "active" : ""}`}
                onClick={() => setActiveTab(2)}
              >
                Liquidity Depth
              </button>
            </div>

            <div className="chart-container">
              <canvas ref={chartRef}></canvas>
            </div>

            <div className="chart-legend">
              <div className="legend-item">
                <div
                  className="legend-color"
                  style={{ background: "#3b82f6" }}
                ></div>
                <span>APY (%)</span>
              </div>
              <div className="legend-item">
                <div
                  className="legend-color"
                  style={{ background: "#8b5cf6", opacity: 0.3 }}
                ></div>
                <span>TVL ($M)</span>
              </div>
            </div>
          </div>

          {/* CARD SECTION */}
          <div className="card-section">
            {/* Protocol Safety */}
            <div className="metric-group">
              <div className="metric-group-title">
                <span className="status-icon">🛡️</span>
                Protocol Safety
              </div>
              <div className="metric-row">
                <span className="metric-label">Audit Status</span>
                <span className="metric-value positive">✓ 3 Audits</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Auditors</span>
                <span className="metric-value">Trail of Bits, Spearbit</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Last Audit</span>
                <span className="metric-value">45 days ago</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Exploit History</span>
                <span className="metric-value positive">None</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Time Since Launch</span>
                <span className="metric-value">18 months</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Insurance Coverage</span>
                <span className="metric-value">$10M (Nexus Mutual)</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Oracle Provider</span>
                <span className="metric-value">Chainlink (99.9%)</span>
              </div>

              <div className="risk-score">
                <div className="risk-score-number">92</div>
                <div>
                  <div className="risk-score-label">Smart Contract</div>
                  <div className="risk-score-label">Risk Score</div>
                </div>
              </div>
            </div>

            {/* Capital Efficiency */}
            <div className="metric-group">
              <div className="metric-group-title">
                <span className="status-icon">⚡</span>
                Capital Efficiency
              </div>
              <div className="metric-row">
                <span className="metric-label">Minimum Deposit</span>
                <span className="metric-value">$1,000</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Lock-up Period</span>
                <span className="metric-value positive">None</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Withdrawal Time</span>
                <span className="metric-value">~2 minutes</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Gas Cost (Est.)</span>
                <span className="metric-value">$0.15 USDC</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Capital Utilization</span>
                <span className="metric-value">87%</span>
              </div>
              <div className="progress-bar">
                <div className="progress-fill" style={{ width: "87%" }}></div>
              </div>
              <div className="metric-row" style={{ marginTop: "12px" }}>
                <span className="metric-label">Current Capacity</span>
                <span className="metric-value">$650M → $1.8B</span>
              </div>
            </div>

            {/* Risk Metrics */}
            <div className="metric-group">
              <div className="metric-group-title">
                <span className="status-icon">📊</span>
                Advanced Risk Metrics
              </div>
              <div className="metric-row">
                <span className="metric-label">
                  Sharpe Ratio (90d)
                  <span className="info-tooltip">?</span>
                </span>
                <span className="metric-value positive">2.4</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Max Drawdown</span>
                <span className="metric-value negative">-0.8%</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">VaR (95%, 30d)</span>
                <span className="metric-value negative">-1.2%</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Volatility (σ)</span>
                <span className="metric-value">0.02%</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">BTC Correlation</span>
                <span className="metric-value">0.15</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Counterparty Concentration</span>
                <span className="metric-value positive">
                  3.2% (largest)
                </span>
              </div>
            </div>

            {/* Yield Sustainability */}
            <div className="metric-group">
              <div className="metric-group-title">
                <span className="status-icon">💰</span>
                Yield Sustainability
              </div>
              <div className="yield-breakdown">
                <div className="yield-item sustainable">
                  <span className="yield-label">Base Lending Rate</span>
                  <span className="yield-value">3.2%</span>
                </div>
                <div className="yield-item temporary">
                  <span className="yield-label">Protocol Incentives</span>
                  <span className="yield-value">2.8%</span>
                </div>
                <div className="yield-item sustainable">
                  <span className="yield-label">LP Fees</span>
                  <span className="yield-value">2.5%</span>
                </div>
              </div>
              <div
                className="metric-row"
                style={{ marginTop: "16px", paddingTop: "16px", borderTop: "1px solid #1e293b" }}
              >
                <span className="metric-label">Current APY</span>
                <span className="metric-value positive">8.50%</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Post-Incentive APY</span>
                <span className="metric-value">5.70%</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Incentive End Date</span>
                <span className="metric-value warning">120 days</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Yield Stability (σ)</span>
                <span className="metric-value positive">0.8%</span>
              </div>
            </div>

            {/* Compliance */}
            <div className="metric-group">
              <div className="metric-group-title">
                <span className="status-icon">✓</span>
                Compliance & Monitoring
              </div>
              <div className="metric-row">
                <span className="metric-label">Jurisdiction</span>
                <span className="metric-value">Switzerland (Zug)</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Sanction Screening</span>
                <span className="metric-value positive">
                  ✓ Active (Elliptic)
                </span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Regulatory Class</span>
                <span className="metric-value">Non-security</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Institutional Eligible</span>
                <span className="metric-value positive">✓ Yes</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Real-time Monitoring</span>
                <span className="metric-value positive">✓ Active</span>
              </div>
              <div className="metric-row">
                <span className="metric-label">Circuit Breaker</span>
                <span className="metric-value positive">
                  TVL -30% trigger
                </span>
              </div>
            </div>

            <button className="cta-button">Allocate Capital to Morpho Blue</button>
          </div>
        </div>
      </div>
    </div>
  );
};
