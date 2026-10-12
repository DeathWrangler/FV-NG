package Widgets.Windows.Subscriptions
{
   import Classes.Animal;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class SubscriptionUnicornDropContainer extends ZwFrame
   {
      
      private const TITLE_TF:String = "unicornTitle_tf";
      
      private const ICON_MC:String = "icon_mc";
      
      private const NAME_TF:String = "unicornName_tf";
      
      private const INFO_TF:String = "unicornBody_tf";
      
      private const TEXT_PREFIX:String = "SubsV2UnicornContainer";
      
      private var m_titleTF:ZwTextField;
      
      private var m_iconMC:FarmIcon;
      
      private var m_nameTF:ZwTextField;
      
      private var m_infoTF:ZwTextField;
      
      public function SubscriptionUnicornDropContainer(element:DisplayObject, unicornItemCode:String)
      {
         super(element);
         this.populate(unicornItemCode);
      }
      
      private function populate(unicornItemName:String = "") : void
      {
         var unicornItem:FarmItem = null;
         var unicornName:String = null;
         var unicornExportName:String = null;
         var unicornAsset:String = null;
         if(Boolean(unicornItemName) && unicornItemName != "")
         {
            unicornItem = Global.farmGameSettingsManager.getFarmItemByName(unicornItemName);
            if(unicornItem)
            {
               unicornName = unicornItem.friendlyTitle;
               unicornExportName = unicornItem.name + "_" + Animal.STATE_FRONT_IDLE;
               if(unicornItem.overrideExportName != "")
               {
                  unicornExportName = unicornItem.overrideExportName + "_" + Animal.STATE_FRONT_IDLE;
               }
               unicornAsset = unicornItem.imageRelativeUrl(Animal.STATE_FRONT_IDLE);
               if(m_element.hasOwnProperty(this.TITLE_TF))
               {
                  this.m_titleTF = addWidget(new ZwTextField(m_element[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_PREFIX + "_Title"))) as ZwTextField;
               }
               if(m_element.hasOwnProperty(this.INFO_TF))
               {
                  this.m_infoTF = addWidget(new ZwTextField(m_element[this.INFO_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_PREFIX + "_Desc"))) as ZwTextField;
               }
               if(m_element.hasOwnProperty(this.NAME_TF))
               {
                  this.m_nameTF = addWidget(new ZwTextField(m_element[this.NAME_TF],unicornName)) as ZwTextField;
               }
               if(m_element.hasOwnProperty(this.ICON_MC))
               {
                  this.m_iconMC = addWidget(new FarmIcon(m_element[this.ICON_MC],unicornItem.getImageByName("feed"))) as FarmIcon;
               }
            }
         }
      }
   }
}

