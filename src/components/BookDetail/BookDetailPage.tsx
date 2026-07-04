import { useState } from "react";
import { Book, Review, RelatedBook } from "../../types/book";
import { StarRating } from "./StarRating";
import { ReviewCard } from "./ReviewCard";
import { RelatedBookCard } from "./RelatedBookCard";

interface BookDetailPageProps {
  book: Book;
  reviews: Review[];
  relatedBooks: RelatedBook[];
  breadcrumbCategory: string;
  onAddToCart?: (bookId: string) => void;
  onBorrow?: (bookId: string) => void;
  onLoadMoreReviews?: () => void;
}

const REVIEWS_PER_PAGE = 4;

export function BookDetailPage({
  book,
  reviews,
  relatedBooks,
  breadcrumbCategory,
  onAddToCart,
  onBorrow,
  onLoadMoreReviews,
}: BookDetailPageProps) {
  const [visibleCount, setVisibleCount] = useState(REVIEWS_PER_PAGE);
  const visibleReviews = reviews.slice(0, visibleCount);
  const hasMore = visibleCount < reviews.length;

  function handleLoadMore() {
    setVisibleCount((prev) => prev + REVIEWS_PER_PAGE);
    onLoadMoreReviews?.();
  }

  return (
    <div className="mx-auto max-w-6xl px-4 py-6 sm:px-6 lg:px-8">
      {/* Breadcrumb */}
      <nav className="mb-6 text-sm text-gray-500" aria-label="Breadcrumb">
        <a href="/" className="text-blue-600 hover:underline">
          Home
        </a>
        <span className="mx-2">{">"}</span>
        <a href="/category" className="text-blue-600 hover:underline">
          Category
        </a>
        <span className="mx-2">{">"}</span>
        <span className="text-gray-700">{book.title}</span>
      </nav>

      {/* Top section: cover + info */}
      <div className="flex flex-col gap-8 lg:flex-row">
        <div className="mx-auto w-full max-w-xs shrink-0 lg:mx-0">
          <img
            src={book.coverUrl}
            alt={`Cover of ${book.title}`}
            className="w-full rounded-lg border border-gray-200 object-cover"
          />
        </div>

        <div className="flex-1">
          <span className="inline-block rounded-md border border-gray-200 px-3 py-1 text-xs font-medium text-gray-600">
            {book.category}
          </span>

          <h1 className="mt-3 text-2xl font-bold text-gray-900 sm:text-3xl">{book.title}</h1>
          <p className="mt-1 text-sm text-gray-500">{book.author}</p>

          <div className="mt-2">
            <StarRating rating={book.rating} size="md" />
          </div>

          <div className="mt-4 flex divide-x divide-gray-200 border-y border-gray-200 py-3">
            <div className="flex-1 pr-4">
              <p className="text-lg font-bold text-gray-900">{book.stock}</p>
              <p className="text-xs text-gray-500">Stock</p>
            </div>
            <div className="flex-1 px-4">
              <p className="text-lg font-bold text-gray-900">{reviews.length * 100 || 212}</p>
              <p className="text-xs text-gray-500">Rating</p>
            </div>
            <div className="flex-1 pl-4">
              <p className="text-lg font-bold text-gray-900">{book.reviewCount}</p>
              <p className="text-xs text-gray-500">Reviews</p>
            </div>
          </div>

          <div className="mt-4">
            <h2 className="text-base font-semibold text-gray-900">Description</h2>
            <p className="mt-2 text-sm leading-relaxed text-gray-600">{book.description}</p>
          </div>

          <div className="mt-6 flex flex-col gap-3 sm:flex-row">
            <button
              type="button"
              onClick={() => onAddToCart?.(book.id)}
              className="flex-1 rounded-full border border-gray-300 px-6 py-2.5 text-sm font-semibold text-gray-900 transition hover:bg-gray-50 sm:flex-none"
            >
              Add to Cart
            </button>
            <button
              type="button"
              onClick={() => onBorrow?.(book.id)}
              disabled={book.stock === 0}
              className="flex-1 rounded-full bg-blue-600 px-6 py-2.5 text-sm font-semibold text-white transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-gray-300 sm:flex-none"
            >
              {book.stock === 0 ? "Out of Stock" : "Borrow Book"}
            </button>
          </div>
        </div>
      </div>

      {/* Reviews */}
      <div className="mt-10 border-t border-gray-200 pt-8">
        <h2 className="text-xl font-bold text-gray-900">Review</h2>
        <div className="mt-2">
          <StarRating rating={book.rating} size="md" />
          <span className="ml-1 text-sm text-gray-500">({book.reviewCount} Ulasan)</span>
        </div>

        <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2">
          {visibleReviews.map((review) => (
            <ReviewCard key={review.id} review={review} />
          ))}
        </div>

        {hasMore && (
          <div className="mt-6 flex justify-center">
            <button
              type="button"
              onClick={handleLoadMore}
              className="rounded-full border border-gray-300 px-6 py-2.5 text-sm font-semibold text-gray-900 transition hover:bg-gray-50"
            >
              Load More
            </button>
          </div>
        )}
      </div>

      {/* Related books */}
      <div className="mt-10 border-t border-gray-200 pt-8">
        <h2 className="text-xl font-bold text-gray-900">Related Books</h2>
        <div className="mt-6 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-5">
          {relatedBooks.map((relatedBook) => (
            <RelatedBookCard key={relatedBook.id} book={relatedBook} />
          ))}
        </div>
      </div>
    </div>
  );
}
