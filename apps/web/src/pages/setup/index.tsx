import { Header } from '@simple-run/ui/header'
import Head from 'next/head'

import { RepoCard } from './repo-card'
import { RepoInput } from './repo-input'
import { SimpleRunCode } from './simple-run-code'
import { SimpleRunConfig } from './simple-run-config'

export default function Setup(): JSX.Element {
  return (
    <section className="h-full flex flex-col justify-center items-center p-6 md:p-12">
      <Head>
        <title>Setup your app with Simple Run</title>
      </Head>
      <Header className="text-center max-w-4xl" title="Let's setup your application to run locally!" />
      <section className="max-w-sm md:max-w-4xl w-full mt-6 md:mt-12">
        <div className="p-3 md:p-6 space-y-3 md:space-y-6 shadow rounded-lg bg-slate-200 dark:bg-slate-800">
          <RepoInput />
          <RepoCard />
          <SimpleRunConfig />
        </div>
      </section>
      <SimpleRunCode />
    </section>
  )
}
