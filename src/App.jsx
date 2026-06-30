import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Shield, Check, Wind, AlertCircle, BarChart2, MessageSquare, Home, User, ChevronRight, Activity, Lock } from 'lucide-react';
import Onboarding from './components/Onboarding';
import { InsightScreen, SignupScreen } from './components/Activation';
import { Dashboard, CheckInFlow, evaluateRisk } from './components/Core';
import { ResetProtocol, RelapseLogging } from './components/Resilience';

// --- COMPONENTS ---

const Splash = ({ onComplete }) => {
    useEffect(() => {
        const timer = setTimeout(onComplete, 2000);
        return () => clearTimeout(timer);
    }, [onComplete]);

    return (
        <motion.div
            className="splash-screen"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.6 }}
            style={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                height: '100vh',
                backgroundColor: 'var(--bg-primary)'
            }}
        >
            <motion.h1
                initial={{ y: 10, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.2, duration: 0.8 }}
                style={{ color: 'var(--accent-sage)', fontSize: '3rem', marginBottom: '0.5rem' }}
            >
                Stira
            </motion.h1>
            <motion.p
                initial={{ y: 10, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.4, duration: 0.8 }}
                style={{ color: 'var(--text-secondary)', fontSize: '1.2rem' }}
            >
                Stability over impulse.
            </motion.p>
        </motion.div>
    );
};

const Welcome = ({ onGetStarted, onLogin }) => {
    return (
        <motion.div
            className="welcome-screen"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            style={{ padding: '2rem', height: '100vh', display: 'flex', flexDirection: 'column' }}
        >
            <div style={{ flex: 1.5 }}></div>
            <div style={{ flex: 2, textAlign: 'center' }}>
                <h1 style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>You’re not broken.</h1>
                <p style={{ color: 'var(--text-secondary)', fontSize: '1.25rem' }}>
                    You’re building stability.
                </p>
            </div>
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                <button className="btn-primary" onClick={onGetStarted}>Get Started</button>
                <button className="btn-outline" onClick={onLogin}>Log In</button>
                <div style={{ textAlign: 'center', marginTop: '1rem', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                    Private. Encrypted. Yours.
                </div>
            </div>
        </motion.div>
    );
};

const CommitmentScreen = ({ onStart }) => (
    <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        style={{ padding: '2rem', height: '100vh', display: 'flex', flexDirection: 'column', justifyContent: 'center', textAlign: 'center' }}
    >
        <Activity size={48} style={{ color: 'var(--accent-sage)', margin: '0 auto 2rem' }} />
        <h2 style={{ fontSize: '2.2rem', marginBottom: '1rem' }}>Let’s begin.</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '1.2rem', marginBottom: '3rem' }}>
            Log your first check-in to establish your baseline.
        </p>
        <button className="btn-primary" onClick={onStart}>Start Check-In</button>
    </motion.div>
);

// --- MAIN APP ---

export default function App() {
    const [view, setView] = useState('splash');
    const [onboardingData, setOnboardingData] = useState({});
    const [user, setUser] = useState(null);
    const [daysSteady, setDaysSteady] = useState(0);
    const [riskState, setRiskState] = useState({ score: 0, state: "Low", color: "var(--accent-sage)" });

    const navigate = (newView) => setView(newView);

    const handleFinishOnboarding = (data) => {
        setOnboardingData(data);
        setDaysSteady(parseInt(data.step4) || 0);
        navigate('insight');
    };

    const handleSignup = () => {
        setUser({ email: 'user@example.com' });
        navigate('commitment');
    };

    const handleCheckIn = (data) => {
        // Determine current time period for risk engine
        const hour = new Date().getHours();
        let timeOfDay = "Morning";
        if (hour >= 12 && hour < 18) timeOfDay = "Afternoon";
        else if (hour >= 18 && hour < 22) timeOfDay = "Evening";
        else if (hour >= 22 || hour < 6) timeOfDay = "Late night";

        const risk = evaluateRisk({
            urge: data.urge,
            isAlone: data.isAlone,
            timeOfDay: timeOfDay,
            onboardingRiskWindow: onboardingData.step2
        });

        setRiskState(risk);
        navigate('dashboard');
    };

    const handleRelapseSubmit = (logData) => {
        setDaysSteady(0);
        setRiskState({ score: 10, state: "Elevated", color: "var(--risk-elevated)" });
        navigate('dashboard');
    };

    return (
        <div className="app-container" style={{ opacity: riskState.state === 'Elevated' ? 0.95 : 1 }}>
            <AnimatePresence mode="wait" initial={false}>
                {view === 'splash' && (
                    <Splash key="splash" onComplete={() => navigate('welcome')} />
                )}

                {view === 'welcome' && (
                    <Welcome
                        key="welcome"
                        onGetStarted={() => navigate('onboarding')}
                        onLogin={() => console.log('Login clicked')}
                    />
                )}

                {view === 'onboarding' && (
                    <Onboarding
                        key="onboarding"
                        onFinish={handleFinishOnboarding}
                    />
                )}

                {view === 'insight' && (
                    <InsightScreen
                        key="insight"
                        data={onboardingData}
                        onContinue={() => navigate('signup')}
                    />
                )}

                {view === 'signup' && (
                    <SignupScreen
                        key="signup"
                        onSignup={handleSignup}
                    />
                )}

                {view === 'commitment' && (
                    <CommitmentScreen
                        key="commitment"
                        onStart={() => navigate('checkin')}
                    />
                )}

                {view === 'dashboard' && (
                    <Dashboard
                        key="dashboard"
                        daysSteady={daysSteady}
                        riskState={riskState}
                        onCheckIn={() => navigate('checkin')}
                        onReset={() => navigate('reset')}
                        onNavigate={(v) => navigate(v)}
                    />
                )}

                {view === 'checkin' && (
                    <CheckInFlow
                        key="checkin"
                        onComplete={handleCheckIn}
                    />
                )}

                {view === 'reset' && (
                    <ResetProtocol
                        key="reset"
                        onComplete={() => navigate('dashboard')}
                    />
                )}

                {view === 'relapse' && (
                    <RelapseLogging
                        key="relapse"
                        onSubmit={handleRelapseSubmit}
                        onCancel={() => navigate('dashboard')}
                    />
                )}

                {view === 'insights' && (
                    <div key="insights" style={{ padding: '2rem' }}>
                        <h2 style={{ marginBottom: '2rem' }}>Insights</h2>
                        <div style={{
                            height: '260px',
                            backgroundColor: 'var(--bg-surface)',
                            borderRadius: '16px',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            position: 'relative',
                            overflow: 'hidden'
                        }}>
                            <div style={{ filter: 'blur(30px)', width: '100%', height: '100%', backgroundColor: 'rgba(127, 163, 140, 0.1)' }}></div>
                            <div style={{ position: 'absolute', textAlign: 'center', padding: '1rem' }}>
                                <Lock size={32} style={{ color: 'var(--accent-sage)', marginBottom: '1rem', margin: '0 auto' }} />
                                <p style={{ fontWeight: 500, margin: 0 }}>Unlock deeper patterns.</p>
                                <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '0.5rem' }}>Premium visibility arriving soon.</p>
                            </div>
                        </div>
                        <button className="btn-outline" onClick={() => navigate('dashboard')} style={{ marginTop: '2rem' }}>Back</button>
                    </div>
                )}

                {view === 'profile' && (
                    <div key="profile" style={{ padding: '2rem' }}>
                        <h2 style={{ marginBottom: '2rem' }}>Profile</h2>
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                            {["Account", "Notifications", "Privacy"].map(item => (
                                <div key={item} style={{ padding: '1.25rem', backgroundColor: 'var(--bg-surface)', borderRadius: '12px', display: 'flex', justifyContent: 'space-between' }}>
                                    {item}
                                    <ChevronRight size={18} style={{ color: 'var(--text-secondary)' }} />
                                </div>
                            ))}
                            <div style={{ marginTop: '1rem', padding: '1.25rem', border: '1px solid var(--risk-elevated)', borderRadius: '12px', color: 'var(--risk-elevated)', textAlign: 'center' }}>Delete Account</div>
                        </div>
                        <div style={{ flex: 1 }}></div>
                        <button className="btn-outline" onClick={() => navigate('dashboard')} style={{ marginTop: '2rem' }}>Back</button>
                    </div>
                )}

                {view === 'chat' && (
                    <div key="chat" style={{ padding: '2rem', textAlign: 'center', height: '100vh', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                        <MessageSquare size={48} style={{ color: 'var(--text-secondary)', margin: '0 auto 2rem' }} />
                        <h2 style={{ color: 'var(--text-secondary)' }}>AI Accountability</h2>
                        <p style={{ color: 'var(--text-secondary)' }}>This reflective space is being prepared.</p>
                        <button className="btn-outline" onClick={() => navigate('dashboard')} style={{ marginTop: '2rem' }}>Back</button>
                    </div>
                )}
            </AnimatePresence>

            {/* Relapse shortcut for home only */}
            {view === 'dashboard' && (
                <button
                    onClick={() => navigate('relapse')}
                    style={{
                        position: 'fixed',
                        top: '1.5rem',
                        right: '1.5rem',
                        backgroundColor: 'transparent',
                        color: 'var(--text-secondary)',
                        fontSize: '0.8rem',
                        border: '1px solid var(--bg-surface)',
                        padding: '0.4rem 0.8rem',
                        borderRadius: '8px'
                    }}
                >
                    Reset Stability
                </button>
            )}
        </div>
    );
}
