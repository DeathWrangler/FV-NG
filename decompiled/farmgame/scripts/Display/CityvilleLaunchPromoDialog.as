package Display
{
   import Classes.CityVilleSign;
   import Classes.Constants.CrossPromoConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.CheckBoxController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class CityvilleLaunchPromoDialog extends FarmDynamicDialog
   {
      
      private var m_cityVilleSign:CityVilleSign = null;
      
      public function CityvilleLaunchPromoDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         this.setShortcutAttribute("messageText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","englandsign_promo_message"));
         this.setShortcutAttribute("closeButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","englandsign_promo_close"));
         this.setShortcutAttribute("hideSignMessage",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","englandsign_promo_removeSign"));
         this.setShortcutListener("closeButton",WidgetControllerEvent.BUTTON_PRESSED,this.onClosePressed);
         var cityVilleSigns:Array = Global.world.getObjectsByClass(CityVilleSign);
         if(cityVilleSigns.length > 0)
         {
            this.m_cityVilleSign = cityVilleSigns[0];
         }
         if(null == this.m_cityVilleSign)
         {
            this.setShortcutAttribute("hideSignCheck",BaseWidgetView.ATTRIBUTE_VISIBLE,false);
            this.setShortcutAttribute("hideSignMessage",BaseWidgetView.ATTRIBUTE_VISIBLE,false);
         }
         FarmStatsManager.count("city_xpromo","dialog","impressions");
      }
      
      public function setSign(citySign:CityVilleSign) : void
      {
         this.m_cityVilleSign = citySign;
      }
      
      private function onClosePressed(event:WidgetControllerEvent) : void
      {
         this.checkForRemoveSign();
         FarmStatsManager.count("city_xpromo","dialog","cancel");
         destroy();
      }
      
      private function checkForRemoveSign() : void
      {
         var controller:BaseWidgetController = this.getChildController("mask.page.vert.pos.left.hideSignCheck");
         var shouldHideSign:Boolean = controller.getAttribute(CheckBoxController.ATTRIBUTE_CHECKED);
         if(shouldHideSign && Boolean(this.m_cityVilleSign))
         {
            Global.player.setSeenFlag(CrossPromoConstants.ENGLAND_BILLBOARD_SEEN_FLAG,false);
            this.m_cityVilleSign.hideSign();
            FarmStatsManager.count("city_xpromo","billboard","removed");
         }
      }
   }
}

