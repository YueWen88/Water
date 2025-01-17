workspace "Water"
    architecture "x64"
    -- 设置启动项目
	startproject "Sandbox"
    configurations { "Debug", "Release", "Dist" }

-- 定义变量
outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

-- Include directories relative to root folder (solution directory)
IncludeDir = {}
IncludeDir["GLFW"] = "Water/vendor/GLFW/include"
IncludeDir["Glad"] = "Water/vendor/Glad/include"
IncludeDir["ImGui"] = "Water/vendor/imgui"
IncludeDir["glm"] = "Water/vendor/glm"

include "Water/vendor/GLFW"
include "Water/vendor/Glad"
include "Water/vendor/imgui"

project "Water"
	-- 项目文件夹位置
    location "Water"
    -- 配置类型
    kind "SharedLib"
    language "C++"

	-- 输出目录
    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    -- 中间目录
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

	pchheader "hzpch.h"
	pchsource "Water/src/hzpch.cpp"

    files { 
        "%{prj.name}/src/**.h",
        "%{prj.name}/src/**.cpp",
        "%{prj.name}/vendor/glm/glm/**.hpp",
		"%{prj.name}/vendor/glm/glm/**.inl",
    }

	-- C/C++->常规->附加包含目录
    includedirs
    {
        "%{prj.name}/src",
        "%{prj.name}/vendor/spdlog/include",
        "%{IncludeDir.GLFW}",
        "%{IncludeDir.Glad}",
        "%{IncludeDir.ImGui}",
        "%{IncludeDir.glm}",
    }

    links 
	{ 
		"GLFW",
        "Glad",
        "ImGui",
		"opengl32.lib",
	}

    filter "system:windows"
        cppdialect "C++17" -- C++语言标准
        -- On:代码生成的运行库选项是MTD,静态链接MSVCRT.lib库; 
        -- Off:代码生成的运行库选项是MDD,动态链接MSVCRT.dll库;
        staticruntime "On"
        systemversion "latest" -- WindowsSDK

		-- C++->预处理器->预处理器定义
        defines
        {
            "HZ_PLATFORM_WINDOWS",
            "HZ_BUILD_DLL",
            "GLFW_INCLUDE_NONE",
            "_SILENCE_STDEXT_ARR_ITERS_DEPRECATION_WARNING"
        }
		
		-- 构建后执行命令
        postbuildcommands
        {
	        -- COPY弃用了，改成这样即可
            ("{COPY} %{cfg.buildtarget.relpath} \"../bin/" .. outputdir .. "/Sandbox/\"")
        }

    filter "configurations:Debug"
        defines "HZ_DEBUG"
        buildoptions "/MDd"
        symbols "On"

	filter "configurations:Release"
		defines "HZ_RELEASE"
		buildoptions "/MD"
		optimize "On"

	filter "configurations:Dist"
		defines "HZ_DIST"
		buildoptions "/MD"
		optimize "On"


project "Sandbox"
    location "Sandbox"
    kind "ConsoleApp"
    language "C++"

    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

    files { 
        "%{prj.name}/src/**.h",
        "%{prj.name}/src/**.cpp"
    }

    includedirs
    {
        "Water/vendor/spdlog/include",
        "Water/src",
        "%{IncludeDir.glm}",
    }

    links {
        "Water"
    }

    filter "system:windows"
        cppdialect "C++17"
        staticruntime "On"
        systemversion "latest"

        defines
        {
            "HZ_PLATFORM_WINDOWS",
            "_SILENCE_STDEXT_ARR_ITERS_DEPRECATION_WARNING"
        }

    filter "configurations:Debug"
        defines "HZ_DEBUG"
        buildoptions "/MDd"
        symbols "On"

	filter "configurations:Release"
		defines "HZ_RELEASE"
		buildoptions "/MD"
		optimize "On"

	filter "configurations:Dist"
		defines "HZ_DIST"
		buildoptions "/MD"
		optimize "On"
