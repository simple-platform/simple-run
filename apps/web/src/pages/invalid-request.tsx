import ExclamationTriangleIcon from '@heroicons/react/24/outline/ExclamationTriangleIcon'
import Link from 'next/link'

export function InvalidRequest() {
  return (
    <div className="alert alert-warning text-sm rounded-md mt-3 md:mt-6 transition" role="alert">
      <ExclamationTriangleIcon className="w-6 h-6 md:w-10 md:h-10" />
      <div>
        <div className="font-semibold">Invalid application run request.</div>
        <div>
          Please make sure that the repository is configured properly with
          {' '}
          <Link className="italic font-medium link link-hover" href="/setup">Simple Run</Link>
          .
        </div>
      </div>
    </div>
  )
}
