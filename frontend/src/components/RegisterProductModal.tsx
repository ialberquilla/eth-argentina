'use client';

import { useState } from 'react';

interface RegisterProductModalProps {
  isOpen: boolean;
  onClose: () => void;
}

type ProcessingState = 'idle' | 'registering-ens' | 'assigning-hook' | 'creating-routing' | 'complete';

export const RegisterProductModal = ({ isOpen, onClose }: RegisterProductModalProps) => {
  const [contactAddress, setContactAddress] = useState('');
  const [processingState, setProcessingState] = useState<ProcessingState>('idle');
  const [error, setError] = useState('');

  const handleCreate = async () => {
    // Validate address format
    if (!contactAddress.trim()) {
      setError('Please enter a contact address');
      return;
    }

    if (!contactAddress.match(/^0x[a-fA-F0-9]{40}$/)) {
      setError('Please enter a valid Ethereum address');
      return;
    }

    setError('');

    // Simulate the registration process
    try {
      // Step 1: Registering ENS
      setProcessingState('registering-ens');
      await new Promise(resolve => setTimeout(resolve, 2000));

      // Step 2: Assigning Uniswap Hook
      setProcessingState('assigning-hook');
      await new Promise(resolve => setTimeout(resolve, 2000));

      // Step 3: Creating Routing
      setProcessingState('creating-routing');
      await new Promise(resolve => setTimeout(resolve, 2000));

      // Complete
      setProcessingState('complete');

      // Close modal after success
      setTimeout(() => {
        handleClose();
      }, 1500);
    } catch (err) {
      setError('An error occurred during registration');
      setProcessingState('idle');
    }
  };

  const handleClose = () => {
    setContactAddress('');
    setProcessingState('idle');
    setError('');
    onClose();
  };

  if (!isOpen) return null;

  const isProcessing = processingState !== 'idle' && processingState !== 'complete';
  const isComplete = processingState === 'complete';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        onClick={isProcessing ? undefined : handleClose}
      />

      {/* Modal */}
      <div className="relative bg-card border border-border rounded-xl p-6 w-full max-w-md shadow-2xl">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-foreground">Register New Product</h2>
          {!isProcessing && (
            <button
              onClick={handleClose}
              className="text-muted hover:text-foreground transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          )}
        </div>

        {/* Content */}
        {!isProcessing && !isComplete ? (
          <div className="space-y-4">
            <div>
              <label htmlFor="contactAddress" className="block text-sm font-medium text-foreground mb-2">
                Contact Address
              </label>
              <input
                id="contactAddress"
                type="text"
                value={contactAddress}
                onChange={(e) => setContactAddress(e.target.value)}
                placeholder="0x..."
                className="w-full px-4 py-2 bg-background border border-border rounded-lg text-foreground placeholder-muted focus:outline-none focus:ring-2 focus:ring-primary transition-shadow"
              />
              {error && (
                <p className="mt-2 text-sm text-red-500">{error}</p>
              )}
            </div>

            <button
              onClick={handleCreate}
              className="w-full px-4 py-3 rounded-lg bg-gradient-to-r from-primary via-blue-500 to-secondary text-white font-medium hover:opacity-90 transition-opacity"
            >
              Create
            </button>
          </div>
        ) : (
          <div className="space-y-6">
            {/* Processing Steps */}
            <div className="space-y-4">
              {/* Step 1: Registering ENS */}
              <ProcessingStep
                label="Registering ENS"
                state={
                  processingState === 'registering-ens' ? 'processing' :
                  ['assigning-hook', 'creating-routing', 'complete'].includes(processingState) ? 'complete' : 'pending'
                }
              />

              {/* Step 2: Assigning Uniswap Hook */}
              <ProcessingStep
                label="Assigning Uniswap Hook"
                state={
                  processingState === 'assigning-hook' ? 'processing' :
                  ['creating-routing', 'complete'].includes(processingState) ? 'complete' : 'pending'
                }
              />

              {/* Step 3: Creating Routing */}
              <ProcessingStep
                label="Creating Routing"
                state={
                  processingState === 'creating-routing' ? 'processing' :
                  processingState === 'complete' ? 'complete' : 'pending'
                }
              />
            </div>

            {/* Success Message */}
            {isComplete && (
              <div className="flex items-center justify-center p-4 bg-primary/10 border border-primary/20 rounded-lg">
                <svg className="w-6 h-6 text-primary mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
                <span className="text-primary font-medium">Product registered successfully!</span>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

interface ProcessingStepProps {
  label: string;
  state: 'pending' | 'processing' | 'complete';
}

const ProcessingStep = ({ label, state }: ProcessingStepProps) => {
  return (
    <div className="flex items-center gap-3">
      {/* Icon */}
      <div className={`flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center transition-colors ${
        state === 'complete' ? 'bg-primary/20' :
        state === 'processing' ? 'bg-blue-500/20' :
        'bg-muted/20'
      }`}>
        {state === 'complete' ? (
          <svg className="w-5 h-5 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
        ) : state === 'processing' ? (
          <div className="w-5 h-5 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
        ) : (
          <div className="w-3 h-3 rounded-full bg-muted" />
        )}
      </div>

      {/* Label */}
      <span className={`font-medium transition-colors ${
        state === 'complete' ? 'text-primary' :
        state === 'processing' ? 'text-blue-500' :
        'text-muted'
      }`}>
        {label}
      </span>
    </div>
  );
};
