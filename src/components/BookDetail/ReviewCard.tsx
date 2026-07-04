import { Review } from "../../types/book";
import { formatReviewDate } from "../../utils/formatDate";

export function ReviewCard({ review }: { review: Review }) {
  return (
    <div className="rounded-xl border border-gray-200 p-4">
      <div className="flex items-center gap-3">
        <img
          src={review.userAvatarUrl}
          alt={review.userName}
          className="h-10 w-10 rounded-full object-cover"
        />
        <div>
          <p className="text-sm font-semibold text-gray-900">{review.userName}</p>
          <p className="text-xs text-gray-500">{formatReviewDate(review.createdAt)}</p>
        </div>
      </div>

      <div className="mt-3 flex gap-0.5" aria-label={`Rating ${review.rating} out of 5`}>
        {Array.from({ length: 5 }).map((_, i) => (
          <svg
            key={i}
            viewBox="0 0 20 20"
            className={`h-4 w-4 ${
              i < review.rating ? "fill-amber-400 text-amber-400" : "fill-gray-200 text-gray-200"
            }`}
          >
            <path d="M10 1.5l2.6 5.27 5.82.85-4.21 4.1 1 5.8L10 14.9l-5.21 2.62 1-5.8-4.21-4.1 5.82-.85L10 1.5z" />
          </svg>
        ))}
      </div>

      <p className="mt-3 text-sm leading-relaxed text-gray-600">{review.comment}</p>
    </div>
  );
}
