workspace "Hazel"
    architecture "x64"
    
    configurations
    {
        "Debug",
        "Release",
        "Dist"
    }

    --[[
        setup the startup project,
        or it will failed on the copy command of MSBuild with MSB3073.
        
        reason: 
            Sandbox is not compiled,  
            the bin file doesn't exist, and neither is the directory, 
            then the copy action can't find the target directory
    ]]--
    startproject "Sandbox"

-- Debug-Windows-x64
outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

-- Hazel
project "Hazel"
    location "Hazel"
    kind "SharedLib"
    language "C++"

    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")
    
    files
    {
        "%{prj.name}/src/**.h",
        "%{prj.name}/src/**.cpp",
    }

    includedirs
    {
        "%{prj.name}/vendor/spdlog/include"
    }

    -- filters
    filter "system:windows"
        cppdialect "C++17"
        staticruntime "On"
        systemversion "10.0.19041.0"

        defines
        {
            "HZ_PLATFORM_WINDOWS",
            "HZ_BUILD_DLL"
        }
        
        -- copy dll into app .exe path
        postbuildcommands
        {
            ("{COPY} %{cfg.buildtarget.relpath} ../bin/" .. outputdir .. "/Sandbox")
        }


    filter "configurations:Debug"
        defines "HZ_DEBUG"
        symbols "On"

    filter "configurations:Release"
        defines "HZ_RELEASE"
        optimize "On"
    
    filter "configurations:Dist"
        defines "HZ_DIST"
        optimize "On"


-- Sandbox
project "Sandbox"
    location "Sandbox"
    kind "ConsoleApp"
    language "C++"

    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

    files
    {
        "%{prj.name}/src/**.h",
        "%{prj.name}/src/**.cpp",
    }

    includedirs
    {
        "Hazel/vendor/spdlog/include",
        "Hazel/src"
    }

    links
    {
        "Hazel"
    }

    -- filters
    filter "system:windows"
        cppdialect "C++17"
        staticruntime "On"
        systemversion "10.0.19041.0"

        defines
        {
            "HZ_PLATFORM_WINDOWS"
        }

    filter "configurations:Debug"
        defines "HZ_DEBUG"
        symbols "On"

    filter "configurations:Release"
        defines "HZ_RELEASE"
        optimize "On"

    filter "configurations:DIST"
        defines "HZ_DIST"
        optimize "On"