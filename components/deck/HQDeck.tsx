"use client";

import OracleDeck from "./OracleDeck";
import DivisionStatusDeck from "./DivisionStatusDeck";

export default function HQDeck() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
      <div className="md:col-span-2">
        <OracleDeck />
      </div>
      <DivisionStatusDeck />
    </div>
  );
}
