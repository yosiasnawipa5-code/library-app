interface StarRatingProps {
  rating: number;
  size?: "sm" | "md";
}

export function StarRating({ rating, size = "sm" }: StarRatingProps) {
  const starClass = size === "sm" ? "w-4 h-4" : "w-5 h-5";

  return (
    <span className="inline-flex items-center gap-1">
      <svg
        className={`${starClass} text-amber-400 fill-amber-400`}
        viewBox="0 0 20 20"
        aria-hidden="true"
      >
        <path d="M10 1.5l2.6 5.27 5.82.85-4.21 4.1 1 5.8L10 14.9l-5.21 2.62 1-5.8-4.21-4.1 5.82-.85L10 1.5z" />
      </svg>
      <span className="font-semibold text-sm text-gray-900">{rating}</span>
    </span>
  );
}
