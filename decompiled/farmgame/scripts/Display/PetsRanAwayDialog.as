package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PetsRanAwayDialog extends Dialog
   {
      
      private var m_payFine:GenericButton;
      
      private var m_cancel:GenericButton;
      
      private var m_petItemCode:String;
      
      private var m_petName:String;
      
      private var m_isMale:Boolean;
      
      public function PetsRanAwayDialog(petItemCode:String, petName:String, isMale:Boolean)
      {
         m_dialogAsset = "assets/dialogs/FV_Pets_PopUp_RanAway.swf";
         super();
         this.m_petItemCode = petItemCode;
         this.m_petName = petName;
         this.m_isMale = isMale;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.initDialog();
      }
      
      private function initDialog() : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_petItemCode);
         this.setImage(item.getImageByName("icon"));
         m_window.callOutBox_mc.title_tf.text = ZLocUtils.t("Dialogs","PetRunAwayTitle");
         if(this.m_isMale)
         {
            m_window.callOutBox_mc.callOut_tf.text = ZLocUtils.t("Dialogs","PetRunAwayMaleMessage",{
               "male_name":this.m_petName,
               "male_name_same":this.m_petName,
               "male_name_again":this.m_petName
            });
         }
         else
         {
            m_window.callOutBox_mc.callOut_tf.text = ZLocUtils.t("Dialogs","PetRunAwayFemaleMessage",{
               "female_name":this.m_petName,
               "female_name_same":this.m_petName,
               "female_name_again":this.m_petName
            });
         }
         var petRescueItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("pet_rescue");
         var petRescueCost:Number = 0;
         if(petRescueItem)
         {
            petRescueCost = petRescueItem.cash;
         }
         this.m_payFine = new GenericButton(m_window.callOutBox_mc.pay_bt,this.onPayFineClick);
         this.m_payFine.text = ZLocUtils.t("Dialogs","PetPayFine",{"quantity":petRescueCost});
         this.m_cancel = new GenericButton(m_window.callOutBox_mc.cancel_bt,this.onCancelClick);
         this.m_cancel.text = ZLocUtils.t("FarmGame","Cancel");
      }
      
      protected function onPayFineClick(event:MouseEvent) : void
      {
         event.stopPropagation();
         close();
         MarketWindow.previousPage = 0;
         UI.displayMarketDialog("petsRanAway","animal",null,"pets");
      }
      
      protected function onCancelClick(event:MouseEvent) : void
      {
         event.stopPropagation();
         close();
      }
      
      private function setImage(url:String) : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(url,function(event:Event):void
         {
            var iconMc:* = undefined;
            var newIcon:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               iconMc = m_window.callOutBox_mc.icon_mc;
               iconMc.scaleX = iconMc.scaleY = 1;
               newIcon = icon.content;
               newIcon.x = -newIcon.width / 2;
               newIcon.y = -newIcon.height / 2;
               iconMc.addChild(newIcon);
            }
         });
      }
   }
}

