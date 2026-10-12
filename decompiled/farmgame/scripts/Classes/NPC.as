package Classes
{
   import Engine.Classes.SocialNetworkUser;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Managers.NPCManager;
   import Transactions.TPerformNPCAction;
   
   public class NPC extends Player
   {
      
      public static const DEFAULT_MODEL_FARM_ID:String = "1000";
      
      protected var m_npcData:Object = null;
      
      protected var m_npcId:String = "1000";
      
      protected var m_npcConfig:Object = null;
      
      protected var m_actionsAvailable:Array = new Array();
      
      protected var m_helpedFarm:Boolean = false;
      
      protected var m_rewardData:Array = new Array();
      
      public function NPC(npcid:String, npcConfigData:Object = null)
      {
         this.m_npcData = NPCManager.getInstance().getNPC(npcid);
         this.m_npcId = npcid;
         this.m_npcConfig = npcConfigData;
         super(new SocialNetworkUser(npcid));
         this.preloadAssets();
      }
      
      public static function preloadAssetsStatic(npcConfig:Object) : void
      {
         doAssetPreload(npcConfig);
      }
      
      public static function doAssetPreload(npcConfigData:Object) : void
      {
         var assetList:Array = null;
         var assetLocation:String = null;
         var assetEntry:Object = null;
         if(npcConfigData != null && npcConfigData.assets != null)
         {
            if(npcConfigData.assets.asset is Array)
            {
               assetList = npcConfigData.assets.asset;
               for each(assetEntry in assetList)
               {
                  assetLocation = assetEntry["@attributes"]["location"].toString();
                  if(assetLocation)
                  {
                     LoadingManager.load(Global.getAssetURL(assetLocation),null,LoadingManager.PRIORITY_HIGH);
                  }
               }
            }
            else
            {
               assetLocation = npcConfigData.assets.asset["@attributes"]["location"].toString();
               if(assetLocation)
               {
                  LoadingManager.load(Global.getAssetURL(assetLocation),null,LoadingManager.PRIORITY_HIGH);
               }
            }
         }
      }
      
      public function getFriendBarImage() : String
      {
         var friendBarImage:String = Global.farmGameSettingsManager.getString("NPC_neighborbarimage_" + this.m_npcId);
         if(!friendBarImage || friendBarImage.length < 1)
         {
            friendBarImage = Global.farmGameSettingsManager.getString("NPC_neighborbarimage_" + DEFAULT_MODEL_FARM_ID);
         }
         if(!friendBarImage || friendBarImage.length < 1)
         {
            throw new Error("Could not get friend bar image for NPC ID:" + this.m_npcId + " from game settings");
         }
         return friendBarImage;
      }
      
      protected function preloadAssets() : void
      {
         doAssetPreload(this.m_npcConfig);
      }
      
      public function get npcConfig() : Object
      {
         return this.m_npcConfig;
      }
      
      public function getDisplayName() : String
      {
         return name;
      }
      
      public function getNPCDataName() : String
      {
         var result:String = "";
         if(this.m_npcData != null && this.m_npcData is NPCConfigData)
         {
            result = (this.m_npcData as NPCConfigData).name;
         }
         return result;
      }
      
      public function beginVisitAction(aid:int = -1) : void
      {
         GlobalEngine.log("NPC","Begin Visit Action");
      }
      
      public function addAction(aid:int) : void
      {
         this.m_actionsAvailable.push(aid);
      }
      
      public function onActionSuccess(aid:int, callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TPerformNPCAction(m_id,aid,callback),true);
      }
   }
}

