package Managers.InGameConsole
{
   import Cache.Classes.UI.ZCacheUI;
   import Cache.Interfaces.IZCache;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Classes.WorldObject;
   import Engine.Managers.SoundManager;
   import Managers.WorldManager;
   import com.adobe.serialization.json.JSON;
   import flash.geom.Point;
   import flash.media.Sound;
   import flash.system.ApplicationDomain;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   
   public final class ConsoleFrontEndCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function ConsoleFrontEndCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "fe";
      }
      
      public function applicationDomainInfo() : String
      {
         return describeType(ApplicationDomain.currentDomain).toXMLString();
      }
      
      public function customCall(objectID:Number, functionName:String, ... args) : String
      {
         var output:String = "Object with object id {" + objectID.toString() + "} not found";
         var obj:WorldObject = Global.world.getObjectById(objectID);
         if(obj)
         {
            if(functionName in obj)
            {
               (obj[functionName] as Function).apply(null,args);
               output = obj.getClassName() + ":" + functionName.toString() + " on object with ID {" + objectID.toString() + "} successful";
            }
            else
            {
               output = "Function name {" + functionName.toString() + "} not found on the " + obj.getClassName() + " object with id: " + objectID.toString();
            }
         }
         return output;
      }
      
      public function getAllIds() : String
      {
         var worldObj:WorldObject = null;
         var output:String = "";
         var objects:Array = Global.world.getObjects();
         for(var objIdx:int = 0; objIdx < objects.length; objIdx++)
         {
            worldObj = objects[objIdx] as WorldObject;
            if(worldObj)
            {
               output = output.concat(getQualifiedClassName(worldObj),": id(",worldObj.getId(),")\n");
            }
         }
         return output;
      }
      
      public function getItemInfoFromCode(itemCode:String) : String
      {
         var classInfo:XML = null;
         var v:XML = null;
         var a:XML = null;
         var output:String = "Item code: \'" + itemCode + "\' not found";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(item)
         {
            output = "Information for Item code: \'" + itemCode + "\'\n";
            classInfo = describeType(item);
            output += "Class :" + classInfo.@name.toString() + "\n";
            for each(v in classInfo..variable)
            {
               output += "Variable " + v.@name + "=" + item[v.@name] + " (" + v.@type + ")\n";
            }
            for each(a in classInfo..accessor)
            {
               if(a.@access == "writeonly")
               {
                  output += "Property " + a.@name + " (" + a.@type + ")\n";
               }
               else
               {
                  output += "Property " + a.@name + "=" + item[a.@name] + " (" + a.@type + ")\n";
               }
            }
         }
         return output;
      }
      
      public function playSound(soundPath:String) : String
      {
         var soundId:String = null;
         var soundObject:Sound = null;
         var soundFullFilePath:String = Global.getAssetURL("assets/sounds/" + soundPath);
         var output:String = "Playing sound at: " + soundFullFilePath;
         var soundNameSearch:Array = soundPath.match(/\w+\.mp3/);
         if(soundNameSearch.length > 0)
         {
            soundId = "CONSOLETEST_" + soundNameSearch[0];
            soundObject = SoundManager.getSoundById(soundId);
            if(soundObject != null)
            {
               SoundManager.playSound(soundId);
            }
            else
            {
               SoundManager.addSound(soundId,soundFullFilePath);
            }
         }
         return output;
      }
      
      public function redirectURL(url:String) : String
      {
         var output:String = "Redirecting to " + url;
         Global.farmSocialNetwork.redirectTop(url);
         return output;
      }
      
      public function listAllCommands() : String
      {
         var classInfo:XML = null;
         var module:* = undefined;
         var moduleName:String = null;
         var method:XML = null;
         var output:String = "";
         output = "Functions available: \n\n";
         var commands:Array = [];
         for each(module in InGameConsoleManager.activeModules)
         {
            moduleName = (module as InGameConsoleBaseCommandsModule).moduleName;
            commands = [];
            output += "\nModule: " + moduleName + "\n";
            classInfo = describeType(module);
            for each(method in classInfo..method)
            {
               if(method.@returnType == "String")
               {
                  commands.push(moduleName + "." + method.@name);
               }
            }
            commands.sort();
            output += "- " + commands.join("\n- ") + "\n";
         }
         return output;
      }
      
      public function diagnoseInit() : String
      {
         return Global.postInitSettings.diagnoseInitQueue();
      }
      
      public function addIdleTask(name:String) : String
      {
         var diagnosis:Object = null;
         var output:String = "";
         var taskXML:XML = Global.postInitSettings.getIdleTaskXML(name);
         if(taskXML == null)
         {
            output = "FAILED. Task name " + name + " not found\n";
         }
         else if(!Global.postInitSettings.executeIdleTaskByName(name))
         {
            diagnosis = PrerequisiteUtility.diagnosePrerequisite(taskXML);
            output = "shouldAdd of idleTask:" + name + " failed:\n";
            output += PrerequisiteUtility.parseConsoleDiagnosis(diagnosis);
         }
         return output;
      }
      
      public function help(functionName:String = "") : String
      {
         var output:String = "";
         if(functionName != "")
         {
            output = ZLocUtils.t("FarmGame","InGameConsoleFunction_" + functionName);
            if(output == null || output == "")
            {
               output = "Function doesn\'t exist OR function has no documentation in FarmGame.properties (\'FarmGame:InGameConsoleFunction_" + functionName + "\')";
            }
            output += "\n";
         }
         else
         {
            output = ZLocUtils.t("FarmGame","InGameConsoleFunction_help") + "\n";
         }
         return output;
      }
      
      public function showStats(counter:String = "", kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "") : String
      {
         InGameConsoleManager.startStatsLogging(counter,kingdom,phylum,zclass,family,genus);
         return "Logging Stats to console with filters:\ncounter: " + counter + "\nkingdom: " + kingdom + "\nphylum:" + phylum + "\nzclass: " + zclass + "\nfamily: " + family + "\ngenus: " + genus;
      }
      
      public function hideStats() : String
      {
         InGameConsoleManager.stopStatsLogging();
         return "Stopped Stat Logging to Console";
      }
      
      public function zCacheStat() : String
      {
         var result:String = "";
         var cache:IZCache = GlobalZCache.instance;
         if(cache == null)
         {
            result = "ZCache instance not found";
         }
         else
         {
            result = com.adobe.serialization.json.JSON.encode(cache.stats);
         }
         return result;
      }
      
      public function zCachePrompt() : String
      {
         var zCache:IZCache = GlobalZCache.instance;
         var sandboxUrl:String = Global.getAssetURL(Global.farmGameSettingsManager.getString("zCacheSandboxUrl"));
         var zCacheUI:ZCacheUI = new ZCacheUI(zCache,Global.stage,sandboxUrl,true,true);
         zCacheUI.offsets = new Point(20,0);
         if(zCacheUI)
         {
            zCacheUI.showPermissionsPrompt(null);
         }
         return "ok";
      }
      
      public function loadExpansions() : String
      {
         var result:String = null;
         var worlds:Array = null;
         if(WorldManager.isWorldCacheEnabled())
         {
            worlds = Global.worldManager.conditionallyPreloadWorlds();
            if(worlds.length > 0)
            {
               result = "Caching worlds:" + worlds.join(",");
            }
            else
            {
               result = "No expansion worlds added to cache";
            }
         }
         else if(!WorldManager.isInPreCacheWorldExperiment())
         {
            result = "Not in world cache experiment";
         }
         else
         {
            result = "World cache disabled";
         }
         return result;
      }
      
      public function statWorldCache() : String
      {
         var result:String = null;
         var worlds:Array = null;
         if(WorldManager.isWorldCacheEnabled())
         {
            worlds = Global.worldManager.getCachedWorlds();
            if(worlds.length > 0)
            {
               result = "Worlds in cache:" + worlds.join(",");
            }
            else
            {
               result = "No expansion worlds in cache";
            }
         }
         else if(!WorldManager.isInPreCacheWorldExperiment())
         {
            result = "Not in world cache experiment";
         }
         else
         {
            result = "World cache disabled";
         }
         return result;
      }
   }
}

