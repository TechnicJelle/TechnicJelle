---
tags: [ GameDev, Unity, Planes Tower Defence ]
prev: /blog/2023/01/19/planes-tower-defence-002-pathfinding
atom-id: "019df518-b25f-79fd-8a07-11a427e969bf"
---

# Planes Tower Defence - The Rest

_(This post was written years later, because I found some more early footage)_

## Enemies

The following video was recorded right after I added an enemy object,
which can follow the paths I described in the previous post.

<video src="Peek 2023-01-02 01-08.mp4" controls muted playsinline></video>

I then also added a secondary, faster but weaker enemy, which is red.

## Waves

The waves are defined through Unity ScriptableObjects.
In the next video, you can see a countdown in the Console in the bottom left,
and the ScriptableObjects in the Asset Browser in the bottom right.

<video src="Peek 2023-01-11 20-51.mp4" controls muted playsinline></video>

## UI & Enemy sprites

Enemies now are not just white/red squares anymore, but actual sprites.
I chose the tanks for them.

They now also have health and a health bar.

I added UI in the top left corner that displays the current wave,
and the countdown to the next wave.

In the bottom right is the player's HP, which is not yet implemented in this video:

<video src="Peek 2023-01-14 00-40.mp4" controls muted playsinline></video>

## Towers

It was finally time to actually add the towers!

I added some pre-defined spots where they can be placed in the level.
Players can click on one, and a pop-up menu will appear around there, showing the four available towers types.

The towers point to the nearest enemy, spawn bullets that travel forwards and hit the enemies, doing damage.

Towers only have a limited range and fire rate, which differs per tower type.

In this video, I haven't implemented the currency yet, so I could place towers anywhere and as much as I wanted.

<video src="Peek 2023-01-28 00-22.mp4" controls muted playsinline></video>

## Final Result

I don't have any more videos, but I implemented everything I set out to implement!

There is one level with a few waves, two enemy types, four tower types, player HP and economy.

(Balancing is probably not very good, but that wasn't the goal of this project anyway.)

**The game is freely playable [here](https://technicjelle.com/PlanesTowerDefence/), right in your browser!**

Source code available [here](https://github.com/TechnicJelle/PlanesTowerDefence)
