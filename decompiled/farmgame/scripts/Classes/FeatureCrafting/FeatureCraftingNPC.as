package Classes.FeatureCrafting
{
   import Engine.Managers.TransactionManager;
   import Managers.FeatureCraftingManager;
   import Transactions.TGenericTransaction;
   
   public class FeatureCraftingNPC
   {
      
      public static const ASSET_STATE_IDLE:String = "idle";
      
      private var m_system:FeatureCraftingSystem;
      
      private var m_name:String;
      
      private var m_assetUrl:String;
      
      private var m_assetScale:Number;
      
      private var m_assetX:Number;
      
      private var m_assetY:Number;
      
      private var m_exportPrefix:String;
      
      private var m_iconUrl:String;
      
      private var m_unlockPointCount:int = 0;
      
      private var m_unlockLevel:int = 0;
      
      private var m_unlockCost:int;
      
      private var m_friendlyTitle:String;
      
      private var m_fiction:String;
      
      private var m_prereqName:String;
      
      private var m_useAutoScaling:Boolean = false;
      
      public function FeatureCraftingNPC(system:FeatureCraftingSystem, config:XML)
      {
         super();
         this.m_system = system;
         this.m_name = config.@name.toString();
         this.m_assetUrl = config.assetUrl.toString();
         this.m_assetScale = config.hasOwnProperty("assetScale") ? parseFloat(config.assetScale.toString()) : 1;
         this.m_assetX = config.hasOwnProperty("assetX") ? parseFloat(config.assetX.toString()) : 0;
         this.m_assetY = config.hasOwnProperty("assetY") ? parseFloat(config.assetY.toString()) : 0;
         this.m_exportPrefix = config.exportPrefix.toString();
         this.m_iconUrl = config.iconUrl.toString();
         this.m_unlockLevel = parseInt(config.@unlockLevel.toString());
         this.m_unlockPointCount = this.m_system.getPointsNeededForGivenLevel(this.m_unlockLevel);
         this.m_useAutoScaling = this.m_system.getAutoScaling();
         this.m_unlockCost = config.hasOwnProperty("@unlockCost") ? int(parseInt(config.@unlockCost)) : 0;
         this.m_friendlyTitle = "";
         this.m_fiction = "";
         this.m_prereqName = config.@prereqName.toString();
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get assetUrl() : String
      {
         return this.m_assetUrl;
      }
      
      public function get assetScale() : Number
      {
         return this.m_assetScale;
      }
      
      public function get assetX() : Number
      {
         return this.m_assetX;
      }
      
      public function get assetY() : Number
      {
         return this.m_assetY;
      }
      
      public function get exportPrefix() : String
      {
         return this.m_exportPrefix;
      }
      
      public function get iconUrl() : String
      {
         return this.m_iconUrl;
      }
      
      public function getFullExportName(exportName:String) : String
      {
         return this.m_exportPrefix + exportName;
      }
      
      public function get unlocked() : Boolean
      {
         var paidUnlock:Boolean = this.m_system.npcData.hasOwnProperty(this.name) && Boolean(this.m_system.npcData[this.name].unlocked);
         return this.m_system.points >= this.m_unlockPointCount || paidUnlock;
      }
      
      public function isComplete() : Boolean
      {
         return this.m_system.npcData.hasOwnProperty(this.name) && Boolean(this.m_system.npcData[this.name].complete);
      }
      
      public function get paidUnlocked() : Boolean
      {
         return this.m_system.npcData.hasOwnProperty(this.name) && Boolean(this.m_system.npcData[this.name].unlocked);
      }
      
      public function get unlockLevel() : int
      {
         return this.m_unlockLevel;
      }
      
      public function get unlockNowCost() : int
      {
         var result:int = this.m_unlockCost;
         if(this.m_system.name != FeatureCraftingSystem.SYSTEM_DAIRY_CRAFTING)
         {
         }
         return result;
      }
      
      public function get friendlyTitle() : String
      {
         if(!this.m_friendlyTitle)
         {
            this.m_friendlyTitle = this.m_system.getLocalizedString("NPC_" + this.m_name);
         }
         return this.m_friendlyTitle;
      }
      
      public function get autoScaling() : Boolean
      {
         return this.m_useAutoScaling;
      }
      
      public function get fictionString() : String
      {
         if(!this.m_fiction)
         {
            this.m_fiction = this.m_system.getLocalizedString("NPC_" + this.m_name + "_fiction");
         }
         return this.m_fiction;
      }
      
      public function buyUnlock() : Boolean
      {
         var cost:int = 0;
         var params:Array = null;
         var result:Boolean = false;
         if(!this.unlocked && this.m_unlockPointCount > 0)
         {
            cost = this.unlockNowCost;
            if(cost > 0 && Global.player.canBuyCash(cost))
            {
               Global.player.cash -= cost;
               params = [this.m_system.name,this.m_name];
               TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"buyNPCUnlock",this.onUnlockReturn,params));
               result = true;
            }
         }
         return result;
      }
      
      private function onUnlockReturn(result:Object) : void
      {
         if(result.hasOwnProperty("error"))
         {
         }
         this.m_system.unlockOrderBoard(this.m_name,result);
         this.m_system.refreshCurrentWindow();
      }
      
      public function setUserData(data:Object) : void
      {
      }
      
      public function get prereqName() : String
      {
         return this.m_prereqName;
      }
      
      public function get isNextToUnlock() : Boolean
      {
         var npc:FeatureCraftingNPC = null;
         var npcs:Array = null;
         var result:Boolean = this.m_unlockCost > 0;
         if(!this.unlocked)
         {
            npcs = this.m_system.getNPCs();
            for each(npc in npcs)
            {
               if(!npc.unlocked && npc.name != this.name && npc.m_unlockPointCount < this.m_unlockPointCount)
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getOrderBoard() : FeatureCraftingOrderBoard
      {
         return this.m_system.getOrderBoard(this.name);
      }
   }
}

