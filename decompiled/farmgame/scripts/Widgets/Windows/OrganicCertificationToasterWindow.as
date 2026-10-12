package Widgets.Windows
{
   import Classes.Constants.OrganicStatsConstants;
   import Classes.CraftingCottageBuilding;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class OrganicCertificationToasterWindow extends ToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_PlanetOrganic_Toaster.swf";
      
      private static const STATS_TOASTER:String = "toaster_orgcert";
      
      private var m_harvest:Boolean;
      
      private var m_idle:Boolean;
      
      public function OrganicCertificationToasterWindow(harvest:Boolean = false, idle:Boolean = false)
      {
         super(ASSET_PATH);
         this.m_harvest = harvest;
         this.m_idle = idle;
      }
      
      override protected function postLoadComplete() : void
      {
         var button:FarmAnimatedTextButton = null;
         super.postLoadComplete();
         if(m_window)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","OrganicToaster_title")));
            if(this.m_harvest)
            {
               addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs","OrganicToaster_HarvestDescription")));
               if(m_window["accept_bt"])
               {
                  button = new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","OrganicToaster_HarvestButton"),this.onAccept);
                  addWidget(button,true);
               }
            }
            else if(this.m_idle)
            {
               addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs","OrganicToaster_IdleDescription")));
               if(m_window["accept_bt"])
               {
                  button = new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","OrganicToaster_button"),this.onAccept);
                  addWidget(button,true);
               }
            }
            else
            {
               addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs","OrganicToaster_prizeDescription")));
               if(m_window["accept_bt"])
               {
                  button = new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","OrganicToaster_button"),this.onAccept);
                  addWidget(button,true);
               }
            }
         }
         FarmStatsManager.count(OrganicStatsConstants.ORGANIC_CERT,STATS_TOASTER,"view_orgcert_toaster");
      }
      
      public function onAccept(click:MouseEvent) : void
      {
         var cottage:CraftingCottageBuilding = null;
         if(this.m_harvest && CraftingManager.getInstance().hasPlacedCraftingCottage(CraftingConstants.BAKERY_SKILL))
         {
            cottage = CraftingManager.getInstance().getCottageByCraft(CraftingConstants.BAKERY_SKILL);
            CraftingUI.displayCraftingMainWindow(cottage);
         }
         else
         {
            Global.player.openOrganicMiniMarket();
         }
         FarmStatsManager.count(OrganicStatsConstants.ORGANIC_CERT,STATS_TOASTER,"click_orgcert_toaster");
      }
   }
}

