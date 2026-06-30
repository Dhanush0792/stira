import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Shield, Lightbulb, UserPlus, Lock } from 'lucide-react';

export const InsightScreen = ({ data, onContinue }) => {
    // Logic to derive summary
    const timeMap = {
        "Morning": "mornings",
        "Afternoon": "afternoons",
        "Evening": "evenings",
        "Late night": "late nights"
    };

    const insights = [
        { icon: <Lock size={20} />, text: `${data.step2 || "Late night"} appears most vulnerable` },
        { icon: <Lightbulb size={20} />, text: `${data.step3 || "Boredom"} is a common trigger` },
        { icon: <Shield size={20} />, text: `Stability usually shifts around Day ${Math.min(parseInt(data.step4) || 3, 7)}` }
    ];

    return (
        <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            style={{ padding: '2rem', height: '100vh', display: 'flex', flexDirection: 'column' }}
        >
            <div style={{ flex: 1, paddingTop: '3rem' }}>
                <h2 style={{ fontSize: '2.2rem', marginBottom: '1rem' }}>Here’s what we see.</h2>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem', marginTop: '3rem' }}>
                    {insights.map((insight, idx) => (
                        <div key={idx} style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '1rem',
                            padding: '1.25rem',
                            backgroundColor: 'var(--bg-surface)',
                            borderRadius: '16px'
                        }}>
                            <div style={{ color: 'var(--accent-sage)' }}>{insight.icon}</div>
                            <p style={{ margin: 0, fontSize: '1.1rem' }}>{insight.text}</p>
                        </div>
                    ))}
                </div>
            </div>

            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', paddingBottom: '2rem' }}>
                <p style={{ color: 'var(--text-secondary)', textAlign: 'center', marginBottom: '1.5rem' }}>
                    Awareness builds stability.
                </p>
                <button className="btn-primary" onClick={onContinue}>Save My Plan</button>
            </div>
        </motion.div>
    );
};

export const SignupScreen = ({ onSignup }) => {
    return (
        <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            style={{ padding: '2rem', height: '100vh', display: 'flex', flexDirection: 'column' }}
        >
            <div style={{ flex: 2, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                <h2 style={{ fontSize: '2rem', marginBottom: '2rem' }}>Create your account</h2>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
                    <input
                        type="email"
                        placeholder="Email"
                        style={{
                            padding: '1rem',
                            borderRadius: '12px',
                            border: '1px solid var(--text-secondary)',
                            backgroundColor: 'var(--bg-surface)',
                            color: 'var(--text-primary)'
                        }}
                    />
                    <input
                        type="password"
                        placeholder="Password"
                        style={{
                            padding: '1rem',
                            borderRadius: '12px',
                            border: '1px solid var(--text-secondary)',
                            backgroundColor: 'var(--bg-surface)',
                            color: 'var(--text-primary)'
                        }}
                    />
                    <button className="btn-primary" onClick={onSignup}>Create Account</button>
                </div>
            </div>
            <div style={{ flex: 1 }}></div>
        </motion.div>
    );
};
