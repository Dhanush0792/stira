import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Wind, AlertCircle, CheckCircle, ChevronLeft } from 'lucide-react';

export const ResetProtocol = ({ onComplete }) => {
    const [phase, setPhase] = useState('inhale'); // inhale, exhale
    const [timeLeft, setTimeLeft] = useState(90);

    useEffect(() => {
        const timer = setInterval(() => {
            setTimeLeft(prev => {
                if (prev <= 1) {
                    clearInterval(timer);
                    onComplete();
                    return 0;
                }
                return prev - 1;
            });
        }, 1000);

        const phaseTimer = setInterval(() => {
            setPhase(prev => (prev === 'inhale' ? 'exhale' : 'inhale'));
        }, 4000);

        return () => {
            clearInterval(timer);
            clearInterval(phaseTimer);
        };
    }, [onComplete]);

    return (
        <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            style={{
                position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
                backgroundColor: 'var(--bg-primary)',
                zIndex: 100,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center'
            }}
        >
            <div style={{ position: 'absolute', top: '2rem', right: '2rem', fontSize: '1.2rem', color: 'var(--text-secondary)' }}>
                {Math.floor(timeLeft / 60)}:{(timeLeft % 60).toString().padStart(2, '0')}
            </div>

            <motion.div
                animate={{ scale: phase === 'inhale' ? 1.5 : 1 }}
                transition={{ duration: 4, ease: "easeInOut" }}
                style={{
                    width: '200px',
                    height: '200px',
                    borderRadius: '50%',
                    backgroundColor: 'rgba(127, 163, 140, 0.2)',
                    border: '2px solid var(--accent-sage)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    marginBottom: '3rem'
                }}
            >
                <Wind size={48} style={{ color: 'var(--accent-sage)' }} />
            </motion.div>

            <motion.p
                key={phase}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                style={{ fontSize: '2rem', textTransform: 'capitalize', color: 'var(--accent-sage)' }}
            >
                {phase}...
            </motion.p>
        </motion.div>
    );
};

export const RelapseLogging = ({ onSubmit, onCancel }) => {
    const [trigger, setTrigger] = useState("");
    const [emotion, setEmotion] = useState("");
    const [note, setNote] = useState("");

    return (
        <motion.div initial={{ y: 20, opacity: 0 }} animate={{ y: 0, opacity: 1 }} style={{ padding: '2rem', height: '100vh', display: 'flex', flexDirection: 'column' }}>
            <button onClick={onCancel} style={{ background: 'none', color: 'var(--text-secondary)', display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '2rem', padding: 0 }}>
                <ChevronLeft size={20} /> Back
            </button>

            <h2 style={{ fontSize: '1.8rem', marginBottom: '1rem' }}>Let’s understand what happened.</h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '2.5rem' }}>Patterns are just data. This helps us protect you next time.</p>

            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '2rem' }}>
                <div>
                    <label style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--text-secondary)' }}>Trigger</label>
                    <select
                        value={trigger}
                        onChange={(e) => setTrigger(e.target.value)}
                        style={{ width: '100%', padding: '1rem', borderRadius: '12px', backgroundColor: 'var(--bg-surface)', color: 'var(--text-primary)', border: '1px solid var(--bg-surface)' }}
                    >
                        <option value="">Select Trigger</option>
                        <option value="boredom">Boredom</option>
                        <option value="stress">Stress</option>
                        <option value="scrolling">Social Media</option>
                        <option value="fatigue">Tiredness</option>
                    </select>
                </div>

                <div>
                    <label style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--text-secondary)' }}>Emotion Before</label>
                    <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.75rem' }}>
                        {["Anxious", "Lonely", "Numb", "Restless"].map(e => (
                            <button
                                key={e}
                                className={emotion === e ? "btn-primary" : "btn-outline"}
                                onClick={() => setEmotion(e)}
                                style={{ width: 'auto', padding: '0.5rem 1rem' }}
                            >{e}</button>
                        ))}
                    </div>
                </div>

                <div>
                    <label style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--text-secondary)' }}>Optional Note</label>
                    <textarea
                        placeholder="What was on your mind?"
                        value={note}
                        onChange={(e) => setNote(e.target.value)}
                        style={{ width: '100%', padding: '1rem', borderRadius: '12px', backgroundColor: 'var(--bg-surface)', color: 'var(--text-primary)', border: '1px solid var(--bg-surface)', height: '100px', resize: 'none' }}
                    />
                </div>
            </div>

            <button className="btn-primary" onClick={() => onSubmit({ trigger, emotion, note })} disabled={!trigger || !emotion}>
                Update Pattern
            </button>
        </motion.div>
    );
};
