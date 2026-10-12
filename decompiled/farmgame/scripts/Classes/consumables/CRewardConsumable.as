package Classes.consumables
{
   import Classes.Constants.ToasterIconPaths;
   import Classes.Consumable;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.IconTitleToasterWindow;
   
   public class CRewardConsumable extends Consumable
   {
      
      private static const CONSUMABLE_ICON_SCALE_DEFAULT:Number = 0.7;
      
      private static const CONSUMABLE_ICON_KEY_DEFAULT:String = "default_consumableIconScale";
      
      private static const CONSUMABLE_ICON_KEY_POSTFIX:String = "_consumableIconScale";
      
      protected var m_showToasterOnConsume:Boolean = true;
      
      public function CRewardConsumable(itemName:String)
      {
         var toasterTag:XMLList = null;
         super(itemName);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_item.hasPropertyInDataSource("toasterOnConsume"))
            {
               this.m_showToasterOnConsume = m_item.getBoolFromDataSource("toasterOnConsume","enabled");
            }
         }
         else if(Boolean(m_item.xml) && m_item.xml.hasOwnProperty("toasterOnConsume"))
         {
            toasterTag = m_item.xml.toasterOnConsume;
            if(toasterTag.hasOwnProperty("@enabled"))
            {
               this.m_showToasterOnConsume = String(toasterTag.@enabled) === "false" ? false : true;
            }
         }
      }
      
      override public function onUse() : void
      {
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            UserRewardUtil.grantUserRewardsFromDataSource(getItem().rewardsData);
         }
         else
         {
            UserRewardUtil.grantUserRewardsFromXml(getItem().rewardsXML);
         }
         if(this.m_showToasterOnConsume)
         {
            this.showToaster();
         }
      }
      
      override public function isOptimistic() : Boolean
      {
         return true;
      }
      
      protected function showToaster() : void
      {
         var itemName:String = getItemName();
         var title:String = ZLocUtils.t("Dialogs",itemName + "_toasterTitle");
         var body:String = ZLocUtils.t("Dialogs",itemName + "_toasterMessage");
         var icon:String = getItem().iconUrl;
         var defaultValue:Number = Global.farmGameSettingsManager.getNumber(CONSUMABLE_ICON_KEY_DEFAULT,CONSUMABLE_ICON_SCALE_DEFAULT);
         var iconScaleKey:String = getItemName() + CONSUMABLE_ICON_KEY_POSTFIX;
         var iconScale:Number = Global.farmGameSettingsManager.getNumber(iconScaleKey,defaultValue);
         ToasterManager.getInstance().add(new IconTitleToasterWindow(title,body,icon,ToasterIconPaths.DIALOG_ASSET,iconScale));
      }
   }
}

