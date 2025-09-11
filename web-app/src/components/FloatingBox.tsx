import React from "react";

interface FloatingBoxProps {
  text: string;
}

const FloatingBox: React.FC<FloatingBoxProps> = ({ text }) => {
  return (
    <div className="fixed bottom-6 right-6 bg-white/90 dark:bg-gray-800/90 text-gray-900 dark:text-white shadow-lg rounded-2xl p-4 w-80 border border-gray-300 dark:border-gray-700">
      <p className="text-sm">{text}</p>
    </div>
  );
};

export default FloatingBox;
