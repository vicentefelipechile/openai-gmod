if util.IsBinaryModuleInstalled then return end

local suffix = ({"osx64","osx","linux64","linux","win64","win32"})[
	( system.IsWindows() && 4 || 0 )
	+ ( system.IsLinux() && 2 || 0 )
	+ ( jit.arch == "x86" && 1 || 0 )
	+ 1
]
local fmt = "lua/bin/gm" .. (CLIENT && "cl" || "sv") .. "_%s_%s.dll"
function util.IsBinaryModuleInstalled( name )
	if ( !isstring( name ) ) then
		error( "bad argument #1 to 'IsBinaryModuleInstalled' (string expected, got " .. type( name ) .. ")" )
	elseif ( #name == 0 ) then
		error( "bad argument #1 to 'IsBinaryModuleInstalled' (string cannot be empty)" )
	end

	if ( file.Exists( string.format( fmt, name, suffix ), "GAME" ) ) then
		return true
	end

	-- Edge case - on Linux 32-bit x86-64 branch, linux32 is also supported as a suffix
	if ( jit.versionnum != 20004 && jit.arch == "x86" && system.IsLinux() ) then
		return file.Exists( string.format( fmt, name, "linux32" ), "GAME" )
	end

	return false
end