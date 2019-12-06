---
layout: default
title: Client State Indication in Tigase XMPP Server
nav_order: 5
---

# XEP-0352: Client State Indication in Tigase XMPP Server
{: .no_toc }
**Abstract:** Implementation of CSI in Tigase XMPP Server contains replaceable logic which you can select. This document specifies behavior of CSI with default logic.

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}
---

## 1. Introduction
[XEP-0352: Client State Indication](https://xmpp.org/extensions/xep-0352.html) in section **3.2 Sever behavior** suggest what XMPP server can do when CSI is active and client indicated `inactive` state. However, servers can decide what they will do and how.

## 2. Scope
This document describes only optimizations done by Tigase XMPP Server in case in which client indicated that it is in `inactive` state.

## 3. Server behavior
### 3.1. Handling of incoming presence
When XMPP client indicate that it is in `inactive` state, Tigase XMPP Server blocks all presences which should be sent to this client, which are indicating another client’s state (in `available`, `unavailable`).

Those blocked presences are then placed on a queue, but only last presence from the particular full JID in kept in the queue. Previous presences sent from the same full JID are removed from the queue.

### 3.2. Handling of other stanzas
If any other stanza is sent to the client which indicated that it is in `inactive` state, Tigase XMPP Server flushes presence queue (sends all waiting presences to the XMPP client) and then delivers this stanza.

Tigase XMPP Server behaves in this way, because it is often required that XMPP client is aware of the presence of another client when it needs to process incoming messages.   
