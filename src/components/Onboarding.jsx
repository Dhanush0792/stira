import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

const OnboardingStep = ({ question, options, subtext, onNext, showInput = false, placeholder = "" }) => {
    const [inputValue, setInputValue] = useState("");

    return (
        <motion.div
            initial={{ x: 50, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            exit={{ x: -50, opacity: 0 }}
            transition={{ duration: 0.4 }}
            style={{ display: 'flex', flexDirection: 'column', height: '100%' }}
        >
            <div style={{ marginBottom: '2rem' }}>
                <h2 style={{ fontSize: '1.8rem', marginBottom: '0.5rem' }}>{question}</h2>
                <p style={{ color: 'var(--text-secondary)', fontSize: '1rem' }}>{subtext}</p>
            </div>

            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                {showInput ? (
                    <input
                        type="number"
                        placeholder={placeholder}
                        value={inputValue}
                        onChange={(e) => setInputValue(e.target.value)}
                        style={{
                            padding: '1rem',
                            borderRadius: '12px',
                            border: '1px solid var(--text-secondary)',
                            backgroundColor: 'var(--bg-surface)',
                            color: 'var(--text-primary)',
                            fontSize: '1.2rem'
                        }}
                    />
                ) : (
                    options.map((opt, idx) => (
                        <button
                            key={idx}
                            className="btn-outline"
                            style={{ textAlign: 'left', padding: '1.25rem' }}
                            onClick={() => onNext(opt)}
                        >
                            {opt}
                        </button>
                    ))
                )}
            </div>

            {showInput && (
                <button
                    className="btn-primary"
                    disabled={!inputValue}
                    onClick={() => onNext(inputValue)}
                    style={{ marginTop: '2rem' }}
                >
                    Continue
                </button>
            )}
        </motion.div>
    );
};

export default function Onboarding({ onFinish }) {
    const [step, setStep] = useState(1);
    const [data, setData] = useState({});

    const handleNext = (val) => {
        const newData = { ...data, [`step${step}`]: val };
        setData(newData);
        if (step < 5) {
            setStep(step + 1);
        } else {
            onFinish(newData);
        }
    };

    const steps = [
        {
            question: "How often does this happen?",
            subtext: "This helps us understand your rhythm, no judgment.",
            options: ["Almost daily", "A few times a week", "Once a week", "Occasionally"]
        },
        {
            question: "When is it strongest?",
            subtext: "Knowing your window is the first step to stability.",
            options: ["Morning", "Afternoon", "Evening", "Late night"]
        },
        {
            question: "What usually leads to the impulse?",
            subtext: "Triggers are just patterns we can observe.",
            options: ["Boredom", "Stress", "Loneliness", "Mindless Scrolling", "Habitual Loop"]
        },
        {
            question: "What’s the longest you’ve stayed steady recently?",
            subtext: "Enter the number of days. Your progress builds from here.",
            showInput: true,
            placeholder: "Enter days"
        },
        {
            question: "What matters most right now?",
            subtext: "Select your primary focus for building stability.",
            options: ["Mental Clarity", "Deeper Relationships", "Self-Control", "Peace of Mind"]
        }
    ];

    const currentStep = steps[step - 1];

    return (
        <div style={{ padding: '2rem', height: '100vh', display: 'flex', flexDirection: 'column' }}>
            <div style={{ display: 'flex', gap: '8px', marginBottom: '3rem', justifyContent: 'center' }}>
                {[1, 2, 3, 4, 5].map(s => (
                    <div
                        key={s}
                        style={{
                            width: '8px',
                            height: '8px',
                            borderRadius: '50%',
                            backgroundColor: s <= step ? 'var(--accent-sage)' : 'var(--bg-surface)'
                        }}
                    />
                ))}
            </div>

            <AnimatePresence mode="wait">
                <OnboardingStep
                    key={step}
                    {...currentStep}
                    onNext={handleNext}
                />
            </AnimatePresence>
        </div>
    );
}
