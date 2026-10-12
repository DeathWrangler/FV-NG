package Widgets.Windows.CrossPromo
{
   import Classes.util.ZLocUtils;
   import Managers.CrossPromoManager;
   import Managers.FarmStatsManager;
   import Widgets.Windows.IconTitleToasterWindow;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class ThemedCrossPromoToasterWindow extends IconTitleToasterWindow
   {
      
      private const ICON_SCALE:Number = 0.6;
      
      private const X_OFFSET:int = 12;
      
      private const Y_OFFSET:int = 9;
      
      private var m_promoId:String = "";
      
      public function ThemedCrossPromoToasterWindow(promoId:String, iconScale:Number = 0.6, iconOffset:Point = null)
      {
         super("","","");
         this.m_promoId = promoId;
         var themeXml:XML = Global.farmGameSettingsManager.getWindowThemeXMLByCode(this.m_promoId);
         if(themeXml != null)
         {
            m_title = ZLocUtils.t("Dialogs","CrossPromo_Title");
            m_text = ZLocUtils.t("Dialogs",this.m_promoId + "_iconTooltip");
            m_iconUrl = themeXml.icon.@url.toString();
            m_iconScale = iconScale;
            if(iconOffset == null)
            {
               m_iconOffset = new Point(this.X_OFFSET,this.Y_OFFSET);
            }
            else
            {
               m_iconOffset = iconOffset;
            }
            m_clickCallback = this.onClick;
         }
         FarmStatsManager.count(this.m_promoId,"toaster_impressions");
      }
      
      protected function onClick(event:MouseEvent) : void
      {
         FarmStatsManager.count(this.m_promoId,"toaster_clicks");
         CrossPromoManager.getInstance().claimReward(this.m_promoId);
      }
   }
}

