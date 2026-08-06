declare module 'jsonld-signatures' {
  export const purposes: {
    AssertionProofPurpose: new () => unknown
  }
  export function sign(
    document: unknown,
    options: { suite: unknown; purpose: unknown; documentLoader?: unknown }
  ): Promise<unknown>
  export function verify(
    document: unknown,
    options: { suite: unknown; purpose: unknown; documentLoader?: unknown }
  ): Promise<{ verified: boolean; error?: { message?: string } }>
}
