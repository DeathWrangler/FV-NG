package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Managers.LicenseManager;
   
   public class MasteryRequirement extends ItemRequirement
   {
      
      private var m_masteryCropName:String;
      
      private var m_masteryLevel:uint;
      
      public function MasteryRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         super(xml,item,dataSource);
         if(m_dataSource)
         {
            this.m_masteryCropName = m_dataSource.getString("name");
            this.m_masteryLevel = uint(m_dataSource.getInt("level"));
         }
         else
         {
            this.m_masteryCropName = xml.@name;
            this.m_masteryLevel = uint(xml.@level);
         }
      }
      
      public function get masteryCropName() : String
      {
         return this.m_masteryCropName;
      }
      
      public function get level() : uint
      {
         return this.m_masteryLevel;
      }
      
      override public function check() : Boolean
      {
         var masteryCrop:FarmItem = null;
         var success:Boolean = false;
         if(LicenseManager.getInstance().hasCurrentLicense(m_item.code))
         {
            success = true;
         }
         else
         {
            masteryCrop = Global.farmGameSettingsManager.getFarmItemByName(this.m_masteryCropName);
            if(masteryCrop)
            {
               if(Global.player.mastery.hasOwnProperty(masteryCrop.code))
               {
                  if(Global.player.mastery[masteryCrop.code] >= this.m_masteryLevel)
                  {
                     success = true;
                  }
               }
            }
         }
         return success;
      }
      
      override public function get identifier() : String
      {
         return FarmItemLock.MASTERY;
      }
      
      override public function getLocalizationsParams() : Array
      {
         var result:Array = this.getLocalizationParamsMultiple();
         result.unshift(m_item.friendlyName);
         return result;
      }
      
      override public function getLocalizationParamsMultiple() : Array
      {
         var result:Array = null;
         var masteryCropFriendlyName:String = "";
         var masteryCrop:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_masteryCropName);
         if(masteryCrop)
         {
            masteryCropFriendlyName = masteryCrop.friendlyName;
         }
         return [masteryCropFriendlyName];
      }
      
      override public function getReadableMessage() : String
      {
         var params:Array = this.getLocalizationsParams();
         return ZLocUtils.t("Dialogs","RequirementMastery_single",{
            "item":ZLocUtils.tk_pk(params[0]),
            "requirement":ZLocUtils.tk_pk(params[1])
         });
      }
      
      override public function getReadableMessageFromParams(paramsArray:Array) : String
      {
         var param:String = null;
         var params:Array = [];
         var masteryNames:String = null;
         for each(param in paramsArray)
         {
            if(masteryNames == null)
            {
               masteryNames = "";
            }
            else
            {
               masteryNames += "\n";
            }
            masteryNames += ZLocUtils.tk_pk_asTitle(param);
         }
         params.push(m_item.friendlyName,masteryNames);
         return ZLocUtils.t("Dialogs","RequirementMastery_multiple",{
            "item":ZLocUtils.tk_pk(params[0]),
            "requirementList":params[1]
         });
      }
   }
}

