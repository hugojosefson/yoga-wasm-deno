/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @format
 */

import type { Yoga } from "./wrapAsm.d.ts";

export * from "./generated/YGEnums.d.ts";
export * from "./wrapAsm.d.ts";

export default function loadYoga(): Promise<Yoga>;
export type { Yoga };
