'use client'

import { Header } from '@simple-run/ui/header'

import { RepoCard } from './repo-card'
import { RepoInput } from './repo-input'
import { SimpleRunConfig } from './simple-run-config'

export default function Page(): JSX.Element {
  return (
    <main className="h-full flex flex-col justify-center items-center p-6 md:p-12">
      <Header className="text-center max-w-3xl" title="Let's setup your project to run locally!" />
      <section className="max-w-sm md:max-w-3xl w-full mt-6 md:mt-12 space-y-3 md:space-y-6">
        <RepoInput />
        <RepoCard />
        <SimpleRunConfig />
      </section>
    </main>
  )
}
