package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   
   public class WorldLicenseRequirement extends ItemRequirement
   {
      
      private static const ATTR_LICENSE_TYPE:String = "@licenseType";
      
      public static const DEFAULT_WORLD_LICENSE_TYPE:String = "world";
      
      private var m_worldId:String = null;
      
      private var m_type:String = null;
      
      private var m_worldRequirement:WorldRequirement;
      
      public function WorldLicenseRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         var type:String = null;
         var checkWorld:Boolean = false;
         super(xml,item,dataSource);
         if(m_dataSource)
         {
            this.m_worldId = m_dataSource.getString("name");
            type = m_dataSource.getString("licenseType");
            checkWorld = m_dataSource.getBoolean("checkWorld");
         }
         else
         {
            this.m_worldId = xml.@name;
            type = xml[ATTR_LICENSE_TYPE];
            checkWorld = Boolean(xml.@checkWorld);
         }
         if(checkWorld)
         {
            this.m_worldRequirement = new WorldRequirement(xml,item,dataSource);
         }
         if(type == null || type == "")
         {
            this.m_type = DEFAULT_WORLD_LICENSE_TYPE;
         }
         else
         {
            this.m_type = type;
         }
      }
      
      override public function check() : Boolean
      {
         var result:Boolean = false;
         var hasLicense:Boolean = Global.worldManager.hasWorldContentLicense(this.m_worldId,this.m_type);
         if(hasLicense == true)
         {
            result = true;
         }
         if(this.m_worldRequirement)
         {
            result ||= this.m_worldRequirement.check();
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
         return FarmItemLock.WORLD_LICENSE;
      }
      
      override public function getReadableMessage() : String
      {
         return ZLocUtils.t("Dialogs","RequirementWorldLicense",{"world":Global.worldManager.getWorldFriendlyName(this.m_worldId)});
      }
      
      override public function getShortReadableMessage(marketCardDesc:String = "") : String
      {
         return ZLocUtils.t("Dialogs","RequirementWorldLicenseShort",{"world":Global.worldManager.getWorldFriendlyName(this.m_worldId)});
      }
   }
}

