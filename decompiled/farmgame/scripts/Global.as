package
{
   import Classes.AnimalBreedingConfigSettings;
   import Classes.Avatar.AvatarConfigSettings;
   import Classes.Avatar.FarmAvatar;
   import Classes.CraftConfigSettings;
   import Classes.CrossPromoDescriptorManager;
   import Classes.EmbeddedArt;
   import Classes.FarmGameWorld;
   import Classes.FarmSocialNetwork;
   import Classes.Leaderboard.LeaderboardConfigSettings;
   import Classes.MarketConfigSettings;
   import Classes.MarketRecommendations;
   import Classes.Player;
   import Classes.PriceFormulaSettings;
   import Classes.StorageConfigSettings;
   import Classes.WatchToEarnManager;
   import Classes.ZapCampaignSettings;
   import Classes.util.FarmGameUtil;
   import Classes.util.FarmTimingModule;
   import Classes.util.LoadingMetricsRecorder;
   import Classes.util.ZLocUtils;
   import Display.AssetHashMap;
   import Display.AssetHashMap10;
   import Display.AssetHashMap11;
   import Display.AssetHashMap12;
   import Display.AssetHashMap13;
   import Display.AssetHashMap14;
   import Display.AssetHashMap15;
   import Display.AssetHashMap16;
   import Display.AssetHashMap2;
   import Display.AssetHashMap3;
   import Display.AssetHashMap4;
   import Display.AssetHashMap5;
   import Display.AssetHashMap6;
   import Display.AssetHashMap7;
   import Display.AssetHashMap8;
   import Display.AssetHashMap9;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Init.ActionQueue;
   import Init.XMLDialogsInit;
   import Managers.AssetHashManager;
   import Managers.CategorySpecificSalesManager;
   import Managers.CharityManager;
   import Managers.EosManager;
   import Managers.ExperimentManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FriendManager;
   import Managers.GeoIpManager;
   import Managers.ManagedSalesManager;
   import Managers.NoPopupManager;
   import Managers.PerformanceExperimentManager;
   import Managers.PopupManager;
   import Managers.PostInitActionsManager;
   import Managers.PostInitSettings;
   import Managers.ToolModeManager;
   import Managers.VIPSalesManager;
   import Managers.WorldManager;
   import Managers.WorldScoreSettingsManager;
   import Managers.WorldSettingsManager;
   import Managers.WorldSpecificSalesManager;
   import Transactions.TRefreshGifts;
   import com.adobe.serialization.json.JSONDecoder;
   import com.greensock.plugins.BevelFilterPlugin;
   import com.greensock.plugins.ColorMatrixFilterPlugin;
   import com.greensock.plugins.ColorTransformPlugin;
   import com.greensock.plugins.DropShadowFilterPlugin;
   import com.greensock.plugins.GlowFilterPlugin;
   import com.greensock.plugins.HexColorsPlugin;
   import com.greensock.plugins.RemoveTintPlugin;
   import com.greensock.plugins.TintPlugin;
   import com.greensock.plugins.TweenPlugin;
   import flash.display.Stage;
   import flash.utils.getTimer;
   import mx.utils.Base64Decoder;
   
   public class Global
   {
      
      private static const unusedClasses:UnusedClasses;
      
      public static var farmSocialNetwork:FarmSocialNetwork;
      
      public static var hud:HUD;
      
      public static var ui:UI;
      
      public static var player:Player;
      
      public static var masterLocale:String;
      
      public static var fbLocale:String;
      
      public static var farmGame:FarmGame;
      
      public static var world:FarmGameWorld;
      
      public static var dynamicDialogs:XMLDialogsInit;
      
      public static var storageSettings:StorageConfigSettings;
      
      public static var craftConfigSettings:CraftConfigSettings;
      
      public static var postInitSettings:PostInitSettings;
      
      public static var avatarConfigSettings:AvatarConfigSettings;
      
      public static var leaderboardConfigSettings:LeaderboardConfigSettings;
      
      public static var marketConfigSettings:MarketConfigSettings;
      
      public static var crosspromoDescriptorManager:CrossPromoDescriptorManager;
      
      public static var animalBreedingSettings:AnimalBreedingConfigSettings;
      
      public static var zapCampaignSettings:ZapCampaignSettings;
      
      public static var priceFormulaSettings:PriceFormulaSettings;
      
      public static var subscriptionsUrl:String;
      
      public static var watchToEarn:WatchToEarnManager;
      
      public static var loadingMetricsRecorder:LoadingMetricsRecorder;
      
      public static var DONTHASH_ASSET_PREFIX:String = "#donthash#";
      
      public static var toolMode:Boolean = false;
      
      public static var uiSandboxMode:Boolean = false;
      
      public static var artuploadSandboxMode:Boolean = false;
      
      public static var questTool2Mode:Boolean = false;
      
      public static var sandboxAssets:Object = new Object();
      
      public static var selectedAvatar:FarmAvatar = null;
      
      public static var stage:Stage = null;
      
      public static var farmGameSettingsManager:FarmGameSettingsManager = new FarmGameSettingsManager();
      
      public static var marketRecommendations:MarketRecommendations = new MarketRecommendations();
      
      public static var worldSettingsManager:WorldSettingsManager = new WorldSettingsManager();
      
      public static var worldScoreSettingsManager:WorldScoreSettingsManager = new WorldScoreSettingsManager();
      
      public static var geoIpManager:GeoIpManager = new GeoIpManager();
      
      public static var embeddedArt:EmbeddedArt = new EmbeddedArt();
      
      public static var postInitActions:ActionQueue = new ActionQueue();
      
      public static var lastInputTick:int = 0;
      
      public static var appActive:Boolean = true;
      
      public static var mission:Object = new Object();
      
      public static var missionHostFirstName:String = null;
      
      public static var pendingPresents:int = 0;
      
      public static var featureBuyableGifts:Boolean = false;
      
      public static var experimentManager:ExperimentManager = new ExperimentManager();
      
      public static var eosManager:EosManager = new EosManager();
      
      public static var managedSalesManager:ManagedSalesManager = new ManagedSalesManager();
      
      public static var vipSalesManager:VIPSalesManager = new VIPSalesManager();
      
      public static var worldSpecificSalesManager:WorldSpecificSalesManager = new WorldSpecificSalesManager();
      
      public static var categorySpecificSalesManager:CategorySpecificSalesManager = new CategorySpecificSalesManager();
      
      public static var charityManager:CharityManager = new CharityManager();
      
      public static var nopopupManager:NoPopupManager = new NoPopupManager();
      
      public static var farmTimingModule:FarmTimingModule = new FarmTimingModule();
      
      public static var postInitActionsManager:PostInitActionsManager = new PostInitActionsManager(true);
      
      public static var suppressAllInitUserDialogs:Boolean = false;
      
      public static var suppressAllToasters:Boolean = false;
      
      public static const ANIMATION_STATE_PLAY:int = 0;
      
      public static const ANIMATION_STATE_PAUSE:int = 1;
      
      public static const ANIMATION_STATE_STOP:int = 2;
      
      public static var animationState:int = ANIMATION_STATE_PLAY;
      
      public static var playOverlayEffects:Boolean = true;
      
      public static var flashHotParams:Object = new Object();
      
      public static var fuelRewardLink:String = null;
      
      public static var witherOnObject:Object = new Object();
      
      public static var quickDeleteOn:Boolean = false;
      
      public static var persistentSell:Boolean = false;
      
      public static var preloaderComplete:Boolean = true;
      
      public static var popupManager:PopupManager = null;
      
      public static var worldManager:WorldManager = new WorldManager();
      
      public static var friendManager:FriendManager = null;
      
      public static var errorPopupEnabled:Boolean = false;
      
      protected static var m_startingWaitTime:Number = 0;
      
      private static var m_isMarket2Experiment:int = -1;
      
      private static var m_enableDebugKeys:Boolean = true;
      
      public static var overrideDebugKeys:Boolean = false;
      
      public static var disableToolTips:Boolean = false;
      
      public static var mapUrls:Object = null;
      
      public static var FB_GRAPH_VERSION:String = "2.0";
      
      private static var m_isInOptimizedSwfExperimentInitialized:Boolean = false;
      
      private static var m_isInOptimizedSwfExperiment:Boolean = false;
      
      private static var m_isInOptimizedSwfQAExperiment:Boolean = false;
      
      TweenPlugin.activate([TintPlugin,RemoveTintPlugin,ColorTransformPlugin,DropShadowFilterPlugin,ColorMatrixFilterPlugin,BevelFilterPlugin,HexColorsPlugin,GlowFilterPlugin]);
      
      public function Global()
      {
         super();
      }
      
      public static function get startingWaitTime() : Number
      {
         return m_startingWaitTime;
      }
      
      public static function setStartingWaitTime() : void
      {
         m_startingWaitTime = getTimer() / 1000;
      }
      
      public static function set enableDebugKeys(value:Boolean) : void
      {
         m_enableDebugKeys = value;
      }
      
      public static function get enableDebugKeys() : Boolean
      {
         return m_enableDebugKeys && !overrideDebugKeys;
      }
      
      public static function getAssetHashPath(path:String) : String
      {
         var result:String = null;
         var opt_path:String = null;
         var opt_qa_path:String = null;
         if(AssetHashManager.isUsingExternalHash())
         {
            return AssetHashManager.getAssetPath(path);
         }
         if(!m_isInOptimizedSwfExperimentInitialized && Global.experimentManager.initialized)
         {
            m_isInOptimizedSwfExperiment = PerformanceExperimentManager.isInOptimizedSwfExperiment;
            m_isInOptimizedSwfQAExperiment = PerformanceExperimentManager.isInOptimizedSwfQAExperiment;
            m_isInOptimizedSwfExperimentInitialized = true;
         }
         if(m_isInOptimizedSwfExperiment)
         {
            opt_path = path.replace("assets/","assets/opt/");
            if(m_isInOptimizedSwfQAExperiment)
            {
               opt_qa_path = path.replace("assets/","assets/opt_qa/");
            }
         }
         if(AssetHashMap.hasOwnProperty(path))
         {
            path = AssetHashMap[path];
         }
         else if(AssetHashMap2.hasOwnProperty(path))
         {
            path = AssetHashMap2[path];
         }
         else if(AssetHashMap3.hasOwnProperty(path))
         {
            path = AssetHashMap3[path];
         }
         else if(AssetHashMap4.hasOwnProperty(path))
         {
            path = AssetHashMap4[path];
         }
         else if(AssetHashMap5.hasOwnProperty(path))
         {
            path = AssetHashMap5[path];
         }
         else if(AssetHashMap6.hasOwnProperty(path))
         {
            path = AssetHashMap6[path];
         }
         else if(AssetHashMap7.hasOwnProperty(path))
         {
            path = AssetHashMap7[path];
         }
         else if(AssetHashMap8.hasOwnProperty(path))
         {
            path = AssetHashMap8[path];
         }
         else if(AssetHashMap9.hasOwnProperty(path))
         {
            path = AssetHashMap9[path];
         }
         else if(AssetHashMap10.hasOwnProperty(path))
         {
            path = AssetHashMap10[path];
         }
         else if(AssetHashMap11.hasOwnProperty(path))
         {
            path = AssetHashMap11[path];
         }
         else if(AssetHashMap12.hasOwnProperty(path))
         {
            path = AssetHashMap12[path];
         }
         else if(AssetHashMap13.hasOwnProperty(path))
         {
            path = AssetHashMap13[path];
         }
         else if(AssetHashMap14.hasOwnProperty(path))
         {
            path = AssetHashMap14[path];
         }
         else if(AssetHashMap15.hasOwnProperty(path))
         {
            path = AssetHashMap15[path];
         }
         else if(AssetHashMap16.hasOwnProperty(path))
         {
            path = AssetHashMap16[path];
         }
         if(m_isInOptimizedSwfExperiment)
         {
            if(AssetHashMap.hasOwnProperty(opt_path))
            {
               path = AssetHashMap[opt_path];
            }
            else if(AssetHashMap2.hasOwnProperty(opt_path))
            {
               path = AssetHashMap2[opt_path];
            }
            else if(AssetHashMap3.hasOwnProperty(opt_path))
            {
               path = AssetHashMap3[opt_path];
            }
            else if(AssetHashMap4.hasOwnProperty(opt_path))
            {
               path = AssetHashMap4[opt_path];
            }
            else if(AssetHashMap5.hasOwnProperty(opt_path))
            {
               path = AssetHashMap5[opt_path];
            }
            else if(AssetHashMap6.hasOwnProperty(opt_path))
            {
               path = AssetHashMap6[opt_path];
            }
            else if(AssetHashMap7.hasOwnProperty(opt_path))
            {
               path = AssetHashMap7[opt_path];
            }
            else if(AssetHashMap8.hasOwnProperty(opt_path))
            {
               path = AssetHashMap8[opt_path];
            }
            else if(AssetHashMap9.hasOwnProperty(opt_path))
            {
               path = AssetHashMap9[opt_path];
            }
            else if(AssetHashMap10.hasOwnProperty(opt_path))
            {
               path = AssetHashMap10[opt_path];
            }
            else if(AssetHashMap11.hasOwnProperty(opt_path))
            {
               path = AssetHashMap11[opt_path];
            }
            else if(AssetHashMap12.hasOwnProperty(opt_path))
            {
               path = AssetHashMap12[opt_path];
            }
            else if(AssetHashMap13.hasOwnProperty(opt_path))
            {
               path = AssetHashMap13[opt_path];
            }
            else if(AssetHashMap14.hasOwnProperty(opt_path))
            {
               path = AssetHashMap14[opt_path];
            }
            else if(AssetHashMap15.hasOwnProperty(opt_path))
            {
               path = AssetHashMap15[opt_path];
            }
            else if(AssetHashMap16.hasOwnProperty(opt_path))
            {
               path = AssetHashMap16[opt_path];
            }
            if(m_isInOptimizedSwfQAExperiment)
            {
               if(AssetHashMap.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap[opt_qa_path];
               }
               else if(AssetHashMap2.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap2[opt_qa_path];
               }
               else if(AssetHashMap3.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap3[opt_qa_path];
               }
               else if(AssetHashMap4.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap4[opt_qa_path];
               }
               else if(AssetHashMap5.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap5[opt_qa_path];
               }
               else if(AssetHashMap6.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap6[opt_qa_path];
               }
               else if(AssetHashMap7.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap7[opt_qa_path];
               }
               else if(AssetHashMap8.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap8[opt_qa_path];
               }
               else if(AssetHashMap9.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap9[opt_qa_path];
               }
               else if(AssetHashMap10.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap10[opt_qa_path];
               }
               else if(AssetHashMap11.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap11[opt_qa_path];
               }
               else if(AssetHashMap12.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap12[opt_qa_path];
               }
               else if(AssetHashMap13.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap13[opt_qa_path];
               }
               else if(AssetHashMap14.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap14[opt_qa_path];
               }
               else if(AssetHashMap15.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap15[opt_qa_path];
               }
               else if(AssetHashMap16.hasOwnProperty(opt_qa_path))
               {
                  path = AssetHashMap16[opt_qa_path];
               }
            }
         }
         return path;
      }
      
      public static function getAssetURL(url:String) : String
      {
         var urlsplit:Array = null;
         var assetName:String = null;
         var hashPath:String = null;
         var mapUrlStr:String = null;
         var decoder:Base64Decoder = null;
         var jdecoder:JSONDecoder = null;
         var stackLimit:int = 0;
         var limitedStackTrace:String = null;
         var values:Array = null;
         var end:int = 0;
         var index:int = 0;
         if(Boolean(url) && url.indexOf(DONTHASH_ASSET_PREFIX) == 0)
         {
            url = url.substr(DONTHASH_ASSET_PREFIX.length);
         }
         else if(Boolean(url) && Boolean(uiSandboxMode) && Boolean(sandboxAssets[url.substring(url.lastIndexOf("/") + 1)]))
         {
            urlsplit = url.substring(url.lastIndexOf("/") + 1).split(".");
            assetName = urlsplit[0] + "." + Global.player.uid + "." + urlsplit[1];
            url = ToolModeManager.getSaltAssetUrl(assetName);
         }
         else if(url != null && url != "")
         {
            url = ZLocUtils.ti(url);
            if(!Global.mapUrls)
            {
               if(GlobalEngine.getFlashVar("mapUrls"))
               {
                  mapUrlStr = String(GlobalEngine.getFlashVar("mapUrls"));
                  decoder = new Base64Decoder();
                  decoder.decode(mapUrlStr);
                  jdecoder = new JSONDecoder(decoder.toByteArray().toString());
                  Global.mapUrls = jdecoder.getValue() as Object;
               }
               else
               {
                  Global.mapUrls = new Object();
               }
            }
            hashPath = getAssetHashPath(url);
            if(Global.mapUrls.hasOwnProperty(hashPath))
            {
               url = Global.mapUrls[hashPath];
            }
            else if(hashPath.indexOf("s3redirect") == 0)
            {
               url = "http://fb-tc-0.farmville.com/" + hashPath;
            }
            else
            {
               url = GlobalEngine.getAssetUrl(hashPath);
            }
         }
         else
         {
            stackLimit = 5;
            limitedStackTrace = FarmGameUtil.getLimitedStackTrace(stackLimit);
            values = limitedStackTrace.split("->");
            if(values.length < stackLimit)
            {
               end = int(values.length);
               for(index = end; index < stackLimit; index++)
               {
                  values.push("");
               }
            }
            FarmStatsManager.sample(100,"Empty_asset_url",values[0],values[1],values[2],values[3],values[4]);
         }
         return url;
      }
      
      public static function reverseAssetURL(imgUrl:String, numFolders:int) : String
      {
         var url:String = imgUrl;
         var stringArray:Array = url.split("/");
         url = "";
         for(var idx:* = int(numFolders + 1); idx > 0; idx--)
         {
            url += stringArray[stringArray.length - idx];
            if(idx > 1)
            {
               url += "/";
            }
         }
         return url;
      }
      
      public static function getItemsAmfPristinePath() : String
      {
         var path:String = GlobalEngine.getFlashVar("items_amf_pristine_version") as String;
         return path + "items.amf.pristine.gz";
      }
      
      public static function getPlayer() : Player
      {
         var playerClass:Class = Object(player).constructor;
         return new playerClass(GlobalEngine.socialNetwork ? GlobalEngine.socialNetwork.getLoggedInUser() : null);
      }
      
      public static function runtimeEnabled(runtimeSwitch:String) : Boolean
      {
         var enabled:Boolean = true;
         if(Boolean(GlobalEngine.getFlashVar(runtimeSwitch)) && GlobalEngine.getFlashVar(runtimeSwitch) == 0)
         {
            enabled = false;
         }
         return enabled;
      }
      
      public static function getXMLPath() : String
      {
         return GlobalEngine.getFlashVar("xml_url") as String;
      }
      
      public static function getMasterAssetHashPath() : String
      {
         var path:String = GlobalEngine.getFlashVar("master_assethash_url") as String;
         return path + "assethash.master.amf.gz";
      }
      
      public static function getMasteryAmfURL() : String
      {
         return GlobalEngine.getFlashVar("masterysigns_amf_url") as String;
      }
      
      public static function setQuickDelete(qDelete:Boolean) : void
      {
         quickDeleteOn = qDelete;
      }
      
      public static function getPersistentSell() : Boolean
      {
         return persistentSell;
      }
      
      public static function setPersistentSell(pSell:Boolean) : void
      {
         persistentSell = pSell;
      }
      
      public static function getQuickDelete() : Boolean
      {
         return quickDeleteOn;
      }
      
      public static function getStarsForMastery(crop:String) : int
      {
         var level:int = 0;
         if(Global.player.mastery.hasOwnProperty(crop))
         {
            level = Global.player.mastery[crop] + 1;
         }
         return level;
      }
      
      public static function getZyngaUserId() : String
      {
         return Global.flashHotParams["ZYNGA_USER_ID"];
      }
      
      public static function get worldTime() : Number
      {
         return worldManager.worldTime;
      }
      
      public static function getCurrentWitherStatus() : Boolean
      {
         var witherStatus:Boolean = true;
         var worldType:String = Global.worldManager.currentWorldType;
         if(Boolean(Global.witherOnObject) && Global.witherOnObject.hasOwnProperty(worldType))
         {
            witherStatus = Boolean(Global.witherOnObject[worldType]);
         }
         return witherStatus;
      }
      
      public static function getCurrentWitherStatusArray(terrainCode:int) : Boolean
      {
         var witherStatus:Boolean = true;
         var worldType:String = Global.worldManager.currentWorldType;
         if(Boolean(Global.witherOnObject) && Global.witherOnObject.hasOwnProperty(worldType))
         {
            if(Global.witherOnObject[worldType].hasOwnProperty(terrainCode))
            {
               witherStatus = Boolean(Global.witherOnObject[worldType][terrainCode]);
            }
            else
            {
               witherStatus = Boolean(Global.witherOnObject[worldType]);
            }
         }
         return witherStatus;
      }
      
      public static function setCurrentWitherStatus(witherOn:Boolean) : void
      {
         var worldType:String = Global.worldManager.currentWorldType;
         if(Global.witherOnObject)
         {
            Global.witherOnObject[worldType] = witherOn;
         }
      }
      
      public static function setCurrentWitherStatusArray(terrainCode:int, witherOn:Boolean) : void
      {
         var worldType:String = Global.worldManager.currentWorldType;
         if(Global.witherOnObject)
         {
            if(Global.witherOnObject.hasOwnProperty(worldType))
            {
               Global.witherOnObject[worldType][terrainCode] = witherOn;
            }
            else
            {
               Global.witherOnObject[worldType] = new Object();
               Global.witherOnObject[worldType][terrainCode] = witherOn;
            }
         }
      }
      
      public static function refreshGifts(result:Object = null) : void
      {
         TransactionManager.addTransaction(new TRefreshGifts(),true);
      }
      
      public static function getFBPicUrl(uid:*) : String
      {
         var fbId:String = String(uid);
         return "https://graph.facebook.com/v" + FB_GRAPH_VERSION + "/" + fbId + "/picture";
      }
   }
}

