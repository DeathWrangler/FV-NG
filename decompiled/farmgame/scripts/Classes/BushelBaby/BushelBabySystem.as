package Classes.BushelBaby
{
   import Classes.Constants.ZLocConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.BushelBabyManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.BushelBaby.BushelBabyContentsWindow;
   import flash.events.Event;
   
   public class BushelBabySystem
   {
      
      public static const SERVICE_NAME:String = "BushelBabyService";
      
      public static const UNLOCK_PROPERTY:String = "unlocked";
      
      public static const COMPLETE_PROPERTY:String = "complete";
      
      public static const LEVEL_PROPERTY:String = "currentLevel";
      
      public static const REWARDS_TYPE:String = "type";
      
      public static const REWARDS_VALUE:String = "value";
      
      public static const LEVELUP_CONST:int = 5;
      
      public static const REWARDS_AMOUNT:String = "amount";
      
      public static const REWARDS_TYPE_ITEMGRANT:String = "item_grant";
      
      public static const DATAKEY_NPCS:String = "npcs_data";
      
      public static const ASSET_DIALOG_MAIN:String = "dialogMain";
      
      public static const ASSET_DIALOG_REWARD:String = "dialogReward";
      
      private var m_currentContentsWindow:BushelBabyContentsWindow;
      
      private var m_name:String;
      
      private var m_buildingItemCode:String;
      
      private var m_prereqs:Array;
      
      private var m_assets:Object;
      
      private var m_npcs:Vector.<BushelBabyNPC>;
      
      private var m_npcData:Object;
      
      private var m_buildingLevel:int;
      
      private var m_friendlyTitle:String;
      
      private var m_buildingLevelRewards:Object;
      
      private var m_buildingLevelCount:int;
      
      public function BushelBabySystem(configXML:XML)
      {
         var image:XML = null;
         var level:XML = null;
         super();
         this.m_name = configXML.@name;
         this.m_buildingItemCode = configXML.@itemCode;
         if(configXML.hasOwnProperty("prereqs"))
         {
            this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(configXML.prereqs.children());
         }
         if(configXML.hasOwnProperty("buildingProgression"))
         {
            this.m_buildingLevelRewards = {};
            this.m_buildingLevelCount = 0;
            for each(level in configXML.buildingProgression.level)
            {
               this.m_buildingLevelRewards[level.@num] = {
                  "xp":level.@xp,
                  "coins":level.@coins
               };
               ++this.m_buildingLevelCount;
            }
         }
         this.m_assets = {};
         for each(image in configXML.images.image)
         {
            this.m_assets[image.@name] = image.@path;
         }
         this.m_npcs = this.getNPCs(configXML);
         this.initUserData();
         FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.refreshFeatureOptions);
      }
      
      public function buildingLevelRewards(level:int) : Object
      {
         return this.m_buildingLevelRewards[level - 1];
      }
      
      public function get buildingLevelCount() : int
      {
         return this.m_buildingLevelCount;
      }
      
      private function getNPCs(configXML:XML) : Vector.<BushelBabyNPC>
      {
         var animalXml:XML = null;
         var recipeXml:XML = null;
         var animalLevels:Array = null;
         var levels:Array = null;
         var npcs:Vector.<BushelBabyNPC> = new Vector.<BushelBabyNPC>();
         var animals:Object = {};
         var recipes:Object = {};
         for each(animalXml in configXML.animals.animal)
         {
            animals[animalXml.@name] = animalXml;
         }
         for each(recipeXml in configXML.crafting.recipes.recipe)
         {
            recipes[recipeXml.@name] = recipeXml;
         }
         animalLevels = [];
         for each(animalXml in configXML.animals.animal)
         {
            if(animals[animalXml.@name])
            {
               levels = [];
               this.extractNPCData(animalXml.@name,animals,recipes,levels);
               npcs.push(new BushelBabyNPC(this,animalXml.@name,levels));
            }
         }
         return npcs;
      }
      
      private function extractNPCData(animalName:String, animals:Object, recipes:Object, levels:Array) : void
      {
         var animal:XML = null;
         var good:XML = null;
         var orderItems:Array = [];
         for each(good in recipes[animalName].goods.good)
         {
            orderItems.push({
               "name":good.@name,
               "required":good.@required
            });
         }
         animal = animals[animalName];
         levels.push({
            "levelNum":levels.length,
            "itemName":animalName,
            "elder":animal.@elder == "true",
            "orderItems":orderItems,
            "unlockCost":recipes[animalName].@unlockCost
         });
         if(animal.hasOwnProperty("nextAnimal"))
         {
            this.extractNPCData(animal.nextAnimal.@name,animals,recipes,levels);
         }
         animals[animalName] = null;
      }
      
      private function refreshFeatureOptions(e:Event) : void
      {
         this.initUserData();
      }
      
      private function initUserData() : void
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_name);
         if(!data)
         {
            data = {};
            data[this.m_name] = {};
            FeatureOptionsManager.getInstance().setFeature(this.m_name,data);
         }
         this.m_npcData = data[this.m_name][DATAKEY_NPCS] = data[this.m_name][DATAKEY_NPCS] || {};
         this.setBuildingLevel();
      }
      
      public function setBuildingLevel() : void
      {
         var completedNPCs:int = this.completedNPCCount();
         this.m_buildingLevel = int(completedNPCs / LEVELUP_CONST) + 1;
      }
      
      public function get buildingLevel() : int
      {
         this.setBuildingLevel();
         return this.m_buildingLevel;
      }
      
      public function incrementComplete(npcName:String) : void
      {
         if(!this.m_npcData[npcName].hasOwnProperty(BushelBabyNPC.COMPLETE_PROPERTY))
         {
            this.m_npcData[npcName][BushelBabyNPC.COMPLETE_PROPERTY] = 1;
         }
         ++this.m_npcData[npcName][BushelBabyNPC.COMPLETE_PROPERTY];
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get buildingItemCode() : String
      {
         return this.m_buildingItemCode;
      }
      
      public function get currentContentsWindow() : BushelBabyContentsWindow
      {
         return this.m_currentContentsWindow;
      }
      
      public function set currentContentsWindow(value:BushelBabyContentsWindow) : void
      {
         this.m_currentContentsWindow = value;
      }
      
      public function arePrerequisitesMet() : Boolean
      {
         return !this.m_prereqs || PrerequisiteUtility.arePrerequisitesMet(this.m_prereqs);
      }
      
      public function getAssetUrl(assetName:String) : String
      {
         var result:String = null;
         if(Boolean(this.m_assets) && Boolean(this.m_assets[assetName]))
         {
            result = this.m_assets[assetName];
         }
         else
         {
            GlobalEngine.assert(false,"Asset not found for " + this.m_name + ":" + assetName + ".");
         }
         return result;
      }
      
      public function grantRewards(rewards:Array) : void
      {
         var reward:Object = null;
         var rewardAmount:int = 0;
         for each(reward in rewards)
         {
            switch(reward[REWARDS_TYPE])
            {
               case REWARDS_TYPE_ITEMGRANT:
                  rewardAmount = 1;
                  if(reward[REWARDS_AMOUNT] != null && reward[REWARDS_AMOUNT] != "")
                  {
                     rewardAmount = parseInt(reward[REWARDS_AMOUNT]);
                  }
                  Global.player.addGift(reward[REWARDS_VALUE],"0",rewardAmount);
            }
         }
      }
      
      public function get npcs() : Vector.<BushelBabyNPC>
      {
         return this.m_npcs;
      }
      
      public function get npcArray() : Array
      {
         var NPCArray:Array = new Array(this.m_npcs.length);
         var i:* = int(this.m_npcs.length);
         while(i--)
         {
            NPCArray[i] = this.m_npcs[i];
         }
         return NPCArray;
      }
      
      public function getNPCData(npcName:String) : Object
      {
         return this.m_npcData[npcName] = this.m_npcData[npcName] || {};
      }
      
      public function setNPCData(npcName:String, property:String, value:*, makeTransaction:Boolean = true) : void
      {
         this.m_npcData[npcName] = this.m_npcData[npcName] || {};
         this.m_npcData[npcName][property] = value;
         var params:Array = [this.m_name,npcName,this.name];
         if(makeTransaction)
         {
            switch(property)
            {
               case BushelBabyNPC.UNLOCK_PROPERTY:
                  params = [this.m_name,npcName];
                  TransactionManager.addTransaction(new TGenericTransaction(BushelBabySystem.SERVICE_NAME,BushelBabyManager.varToFunctionMapping[property],null,params));
                  break;
               case BushelBabyNPC.LEVEL_PROPERTY:
                  params = [this.m_name,npcName,value];
                  TransactionManager.addTransaction(new TGenericTransaction(BushelBabySystem.SERVICE_NAME,BushelBabyManager.varToFunctionMapping[property],null,params));
            }
         }
      }
      
      public function refreshCurrentWindow() : void
      {
         if(this.m_currentContentsWindow)
         {
            this.m_currentContentsWindow.refresh();
         }
      }
      
      public function completedNPCCount() : int
      {
         var npc:BushelBabyNPC = null;
         var completed:int = 0;
         for each(npc in this.m_npcs)
         {
            if(npc.complete || npc.hasCompletedBefore())
            {
               completed++;
            }
         }
         return completed;
      }
      
      public function getLocalizedString(key:String, params:Object = null) : String
      {
         var result:String = "";
         var systemKey:String = key + "_" + this.m_name;
         if(ZLocUtils.hasString(ZLocConstants.PKG_FEATURE_CRAFTING,systemKey))
         {
            result = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,systemKey,params);
         }
         else if(ZLocUtils.hasString(ZLocConstants.PKG_FEATURE_CRAFTING,key))
         {
            result = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,key,params);
         }
         else
         {
            result = key;
         }
         return result;
      }
      
      public function logStats(kingdom:String = "", phylum:String = "") : void
      {
         StatsManager.count(this.m_name + "_Client",kingdom,phylum);
      }
   }
}

