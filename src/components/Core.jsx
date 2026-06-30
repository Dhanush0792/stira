import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Shield, Wind, Check, AlertCircle, Home, BarChart2, MessageSquare, User, Activity, MoreHorizontal, Moon, Sun, Coffee } from 'lucide-react';

// --- RISK EVALUATION ENGINE ---

export const evaluateRisk = (inputs) => {
    const { urge, isAlone, timeOfDay, onboardingRiskWindow } = inputs;
    let score = 0;

    // Urge contribution (0-4)
    if (urge >= 8) score += 4;
    else if (urge >= 5) score += 2;
    else if (urge >= 3) score += 1;

    // Alone status contribution (0-2)
    if (isAlone) score += 2;

    // Time-based contribution (0-4)
    if (timeOfDay === onboardingRiskWindow) score += 4;
    else if (timeOfDay === "Late night") score += 2;

    // Normalize to 0-10
    const finalScore = Math.min(score, 10);

    if (finalScore >= 7) return { score: finalScore, state: "Elevated", color: "var(--risk-elevated)" };
    if (finalScore >= 4) return { score: finalScore, state: "Moderate", color: "var(--risk-moderate)" };
    return { score: finalScore, state: "Low", color: "var(--accent-sage)" };
};

// --- CORE COMPONENTS ---

export const Dashboard = ({ daysSteady, riskState, onCheckIn, onReset, onNavigate }) => {
    return (
        <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            style={{ display: 'flex', flexDirection: 'column', height: '100vh', padding: '1.5rem' }}
        >
            <div style={{ textAlign: 'center', marginTop: '3rem' }}>
                <h1 style={{ fontSize: '5rem', fontWeight: 300, marginBottom: '0.2rem' }}>{daysSteady}</h1>
                <p style={{ color: 'var(--text-secondary)', fontSize: '1.2rem', marginBottom: '1.5rem' }}>Days Steady</p>
                <div style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '0.5rem',
                    padding: '0.5rem 1.25rem',
                    borderRadius: '20px',
                    backgroundColor: 'var(--bg-surface)',
                    border: `1px solid ${riskState.color}`
                }}>
                    <Shield size={16} style={{ color: riskState.color }} />
                    <span style={{ color: riskState.color, fontWeight: 500 }}>{riskState.state} Risk</span>
                </div>
            </div>

            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: '1rem' }}>
                <button className="btn-primary" onClick={onCheckIn} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.75rem' }}>
                    <Activity size={20} /> Check In
                </button>
                <button className="btn-outline" onClick={onReset} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.75rem' }}>
                    <Wind size={20} /> Start Reset
                </button>
            </div>

            <div style={{ backgroundColor: 'var(--bg-surface)', padding: '1.5rem', borderRadius: '16px', marginBottom: '6rem' }}>
                <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
                    <div style={{ color: 'var(--accent-sage)', backgroundColor: 'rgba(127, 163, 140, 0.1)', padding: '0.75rem', borderRadius: '12px' }}>
                        <Activity size={20} />
                    </div>
                    <div>
                        <p style={{ margin: 0, fontWeight: 500 }}>Stability insight</p>
                        <p style={{ margin: 0, fontSize: '0.9rem', color: 'var(--text-secondary)' }}>You handled the last window perfectly.</p>
                    </div>
                </div>
            </div>

            <div style={{
                position: 'fixed',
                bottom: 0,
                left: 0,
                right: 0,
                height: '80px',
                backgroundColor: 'var(--bg-primary)',
                borderTop: '1px solid var(--bg-surface)',
                display: 'flex',
                justifyContent: 'space-around',
                alignItems: 'center',
                padding: '0 1rem'
            }}>
                <button onClick={() => onNavigate('dashboard')} style={{ color: 'var(--accent-sage)', background: 'none' }}><Home /></button>
                <button onClick={() => onNavigate('insights')} style={{ color: 'var(--text-secondary)', background: 'none' }}><BarChart2 /></button>
                <button onClick={() => onNavigate('chat')} style={{ color: 'var(--text-secondary)', background: 'none' }}><MessageSquare /></button>
                <button onClick={() => onNavigate('profile')} style={{ color: 'var(--text-secondary)', background: 'none' }}><User /></button>
            </div>
        </motion.div>
    );
};

export const CheckInFlow = ({ onComplete }) => {
    const [step, setStep] = useState(1);
    const [data, setData] = useState({ urge: 5, mood: "", isAlone: false });

    const next = () => {
        if (step < 3) setStep(step + 1);
        else onComplete(data);
    };

    return (
        <motion.div initial={{ y: 20, opacity: 0 }} animate={{ y: 0, opacity: 1 }} style={{ padding: '2rem', height: '100vh' }}>
            {step === 1 && (
                <div>
                    <h2 style={{ fontSize: '1.8rem', marginBottom: '3rem' }}>How strong is the urge?</h2>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem', color: 'var(--text-secondary)' }}>
                        <span>Low</span>
                        <span style={{ color: 'var(--risk-elevated)' }}>High</span>
                    </div>
                    <input
                        type="range"
                        min="1" max="10"
                        value={data.urge}
                        onChange={(e) => setData({ ...data, urge: parseInt(e.target.value) })}
                        style={{ width: '100%', marginBottom: '3rem', accentColor: 'var(--accent-sage)' }}
                    />
                    <button className="btn-primary" onClick={next}>Continue</button>
                </div>
            )}

            {step === 2 && (
                <div>
                    <h2 style={{ fontSize: '1.8rem', marginBottom: '2rem' }}>How are you feeling?</h2>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginBottom: '3rem' }}>
                        {["Calm", "Anxious", "Bored", "Stressed", "Tired", "Steady"].map(mood => (
                            <button
                                key={mood}
                                className={data.mood === mood ? "btn-primary" : "btn-outline"}
                                onClick={() => setData({ ...data, mood })}
                            >{mood}</button>
                        ))}
                    </div>
                    <button className="btn-primary" onClick={next} disabled={!data.mood}>Continue</button>
                </div>
            )}

            {step === 3 && (
                <div>
                    <h2 style={{ fontSize: '1.8rem', marginBottom: '2rem' }}>Are you alone?</h2>
                    <div style={{ display: 'flex', gap: '1rem', marginBottom: '4rem' }}>
                        <button className={!data.isAlone ? "btn-primary" : "btn-outline"} onClick={() => setData({ ...data, isAlone: false })} style={{ flex: 1 }}>No</button>
                        <button className={data.isAlone ? "btn-primary" : "btn-outline"} onClick={() => setData({ ...data, isAlone: true })} style={{ flex: 1 }}>Yes</button>
                    </div>
                    <button className="btn-primary" onClick={next}>Submit</button>
                </div>
            )}
        </motion.div>
    );
};
