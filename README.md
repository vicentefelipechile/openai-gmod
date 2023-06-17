# OpenAI Garry's Mod

Introducing a new workshop add-on for Garry's Mod that seamlessly connects the game with OpenAI's advanced AI technology.
With this add-on, players can now access exciting features such as:
- the chat function (!chat) which allows for seamless communication between players
- the image generation function (!dalle) which enables players to generate stunning visuals in real-time.

# Modules

## Chat Functions & Hooks

```lua
-- Shared Hook
hook.Add("OpenAI.OnChatReceive", "OpenAI.OnChatReceive", function(ply, prompt, response)

    print( ply:Nick() ) -- vicentefelipechile
    print( prompt )     -- What is OpenAI
    print( response )   -- OpenAI is an blah blah blah...
    
end)
```

## Image Functions & Hooks

```lua
-- Shared Hook
hook.Add("OpenAI.OnImageReceive", "OpenAI.OnImageReceive", function(ply, prompt, url)

    print( ply:Nick() ) -- vicentefelipechile
    print( prompt )     -- A cat in the space
    print( url )        -- https://...

end)


-- Client-side Hook
hook.Add("OpenAI.OnImageDownloaded", "OpenAI.OnImageDownloaded", function(ply, location, prompt)

    print( ply:Nick() ) -- vicentefelipechile
    print( location )   -- openai/image/1681134554_a_cat_in_the_space    <-  Path to the image in "DATA"
    print( prompt )     -- A cat in the space
    
end)
```


# Mapping Latam

- [Github](https://github.com/mapping-latam)
- [Discord](https://discord.gg/GKdJv9ZUMC)
