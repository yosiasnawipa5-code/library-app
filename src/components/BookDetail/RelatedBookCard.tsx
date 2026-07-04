import { RelatedBook } from "../../types/book";
import { StarRating } from "./StarRating";

export function RelatedBookCard({ book }: { book: RelatedBook }) {
  return (
    <a href={`/books/${book.id}`} className="block group">
      <div className="aspect-[3/4] w-full overflow-hidden rounded-lg bg-gray-100">
        <img
          src={book.coverUrl}
          alt={book.title}
          className="h-full w-full object-cover transition-transform group-hover:scale-105"
        />
      </div>
      <p className="mt-2 text-sm font-semibold text-gray-900 line-clamp-1">{book.title}</p>
      <p className="text-xs text-gray-500">{book.author}</p>
      <div className="mt-1">
        <StarRating rating={book.rating} />
      </div>
    </a>
  );
}
