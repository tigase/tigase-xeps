---
layout: default
title: Priority of notifications
has_children: false
parent: Push Notifications
nav_order: 3
---

# Priority of notifications
{: .no_toc }
**Abstract:** This specification defines XMPP protocol extension allowing XMPP clients to inform XMPP server that it SHOULD mark published push notifications as high priority if they contain message.

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}
---

## 1. Introduction
[XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) defines a way for the XMPP server to generate push notifications by publishing them to the application specific XMPP Push Notification Component. However, that extension does not specify any rules for generating push notifications.

This extension was created to provide a way for XMPP client to inform sever that it wants to know priority of sent push notifications.

## 2. Scope
This documents specifies ways of informing XMPP server that clients wants to know priority of published push notifications This extension is an extension to payload send to enable push notifications as specified in [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html).

## 3. Requirements
The XMPP server MUST support [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) as this specification is the extension to push notifications.

## 4. Setting notification priority
Some push notification systems can provide better/faster notifications delivery if they are marked as high priority notifications. However, those notifications CANNOT be dismissed by the XMPP clients and those notifications are always displayed to the user. To be able to use those notifications the XMPP client needs to use push notifications mechanism on the server side. This feature allows the XMPP client to notify push notification component that the server done filtering on the push notifications.

### 4.1. Discovering support
Before enabling this feature, a client SHOULD determine whether the user's server supports marking push notifications as high priority; to do so, it MUST send a  [Service Discovery (XEP-0030)](https://xmpp.org/extensions/xep-0030.html)  [2] information query to the user's bare JID:

**Example 1.** Client queries server regarding protocol support
````xml
<iq from='user@example.com/mobile'
    to='user@example.com'
    id='x13'
    type='get'>
  <query xmlns='http://jabber.org/protocol/disco#info'/>
</iq>
````

**Example 2.** Server communicates protocol support
````xml
<iq from='juliet@capulet.lit'
    to='juliet@capulet.lit/balcony'
    id='disco1'
    type='result'>
  <query xmlns='http://jabber.org/protocol/disco#info'>
    <identity category='account' type='registered'/>
    <feature var='tigase:push:priority:0'/>
    ...
  </query>
</iq>
````

### 4.2. Enabling feature
To enable this feature XMPP client SHOULD send enable request with `<priority />` element qualified by the `tigase:push:priority:0` namespace:

**Example 15.** Enabling feature
````xml
<iq type='set' id='x42'>
  <enable xmlns='urn:xmpp:push:0' jid='push-5.client.example'
    node='yxs32uqsflafdk3iuqo' >
    <priority xmlns='tigase:push:priority:0' />
  </enable>
</iq>
````

**Note:** The XMPP client SHOULD enable this feature ONLY if the XMPP server supports all the required push notifications filtering.

#### 5.1.3. Marking push notification with priority
If this feature is enabled, the XMPP server SHOULD mark high priority notifications by adding `<priority />` element qualified with `tigase:push:priority:0` namespace and value set to `high` to the `<notification />` element of the push notification before publishing it.

**Example 16.** Notification marked as high priority
````xml
<iq type='set'
    from='example.com'
    to='push-5.client.example'
    id='n12'>
  <pubsub xmlns='http://jabber.org/protocol/pubsub'>
    <publish node='yxs32uqsflafdk3iuqo'>
      <item>
        <notification xmlns='urn:xmpp:push:0'>
          <x xmlns='jabber:x:data'>
            <field var='FORM_TYPE'><value>urn:xmpp:push:summary</value></field>
            <field var='message-count'><value>1</value></field>
            <field var='last-message-sender'><value>juliet@capulet.example/balcony</value></field>
            <field var='last-message-body'><value>Wherefore art thou, Romeo?</value></field>
          </x>
          <priority xmlns='tigase:push:priority:0'>high</priority>
        </notification>
      </item>
    </publish>
  </pubsub>
</iq>
````
