package Classes
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Managers.WorldManager;
   import Managers.WorldSeasonsManager;
   
   public class WorldRequirement extends ItemRequirement
   {
      
      protected var m_worldId:String = null;
      
      protected var m_strictMode:Boolean;
      
      public function WorldRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         super(xml,item,dataSource);
         if(m_dataSource)
         {
            this.m_worldId = m_dataSource.getString("name");
            this.m_strictMode = m_dataSource.getBoolean("strict");
         }
         else
         {
            this.m_worldId = xml.@name;
            this.m_strictMode = xml.@strict == "true";
         }
      }
      
      override public function check() : Boolean
      {
         var result:Boolean = false;
         if(Global.worldManager.currentWorldType == this.m_worldId)
         {
            result = true;
         }
         else if(!this.m_strictMode && WorldManager.getWorldRequirementTypeFromWorldType(Global.worldManager.currentWorldType) == this.m_worldId)
         {
            result = true;
         }
         return result;
      }
      
      override public function shouldLockGiftbox() : Boolean
      {
         return true;
      }
      
      override public function shouldLockCashItem() : Boolean
      {
         return true;
      }
      
      override public function get identifier() : String
      {
         return FarmItemLock.WORLD;
      }
      
      override public function getReadableMessage() : String
      {
         var result:String = "";
         if(this.m_worldId == WorldsConstants.WORLD_ID_HOME)
         {
            result = ZLocUtils.t("Dialogs","RequirementWorldHome");
         }
         else
         {
            result = ZLocUtils.t("Dialogs","RequirementWorld",{"world":Global.worldManager.getWorldFriendlyName(this.m_worldId)});
         }
         return result;
      }
      
      override public function getShortReadableMessage(marketCardDesc:String = "") : String
      {
         var readableMessage:String = "";
         if(Boolean(WorldSeasonsManager.getInstance().getNumSeasonsForWorld(this.m_worldId) > WorldSeasonsManager.SEASON_ONE) && Boolean(marketCardDesc) && marketCardDesc != "")
         {
            readableMessage = ZLocUtils.t("Dialogs","RequirementWorldShort" + "_" + marketCardDesc);
         }
         else
         {
            readableMessage = ZLocUtils.t("Dialogs","RequirementWorldShort",{"world":Global.worldManager.getWorldFriendlyName(this.m_worldId)});
         }
         return readableMessage;
      }
      
      public function get worldId() : String
      {
         return this.m_worldId;
      }
   }
}

