package Display
{
   import Classes.Airplane;
   import Classes.Combine;
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.EmbeddedArt;
   import Classes.Equipment;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.HarvestableResource;
   import Classes.Harvester;
   import Classes.IrrigationSprinkler;
   import Classes.MarketIndicatorConfig;
   import Classes.OrchardHarvester;
   import Classes.PlotRemover;
   import Classes.RotatableCombine;
   import Classes.RotatableHarvester;
   import Classes.RotatableOrchardHarvester;
   import Classes.RotatablePlotRemover;
   import Classes.RotatableSeeder;
   import Classes.RotatableTractor;
   import Classes.Seeder;
   import Classes.Terrain.TerrainUtil;
   import Classes.Tractor;
   import Classes.UserDrivenTerrain.UDTMap;
   import Classes.VisitorManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUDSkinConfig;
   import Display.HUD.HUDSkinConfigMenu;
   import Engine.Utilities;
   import Events.ActionMenuEvent;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import GameMode.GMAirplaneFly;
   import GameMode.GMClear;
   import GameMode.GMDecoMove;
   import GameMode.GMDefault;
   import GameMode.GMHarvester;
   import GameMode.GMHarvesterAll;
   import GameMode.GMIrrigationSprinkler;
   import GameMode.GMMultiPlow;
   import GameMode.GMPlotRemover;
   import GameMode.GMSuperAvatarHarvest;
   import GameMode.GMSuperAvatarPlow;
   import GameMode.GMTractorPlow;
   import GameMode.GMTractorPlowAll;
   import Managers.Crafting.CraftingManager;
   import Managers.DecoratorModeManager;
   import Managers.DragonBreedingManager;
   import Managers.ExchangeManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Managers.FeatureMessagingManager;
   import Managers.IrrigationManager;
   import Managers.ItemContestManager;
   import Managers.ItemMembershipManager;
   import Managers.LeaderboardManager;
   import Managers.LimboInnovationManager;
   import Managers.MarketStatsManager;
   import Managers.PetManager;
   import Managers.TurboPPHManager;
   import Managers.UDTManager;
   import Widgets.Windows.BushelReportWindow;
   import Widgets.Windows.Collections.CollectionsWindow;
   import Widgets.Windows.CombineOnboardingWindow;
   import Widgets.Windows.GiftBox.GiftBoxWindow;
   import Widgets.Windows.IrelandInnovationMainWindow;
   import Widgets.Windows.ItemFinderWindow;
   import Widgets.Windows.Market.MarketWindow;
   import Widgets.Windows.MarketIndicatorWindow;
   import Widgets.Windows.Mastery.MasteryWindow;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class ActionMenu extends Sprite
   {
      
      protected const MARKET_ICON_ASSET_NAME_NORMAL:String = "hud_act_market";
      
      protected const MARKET_ICON_ASSET_NAME_SALE:String = "hud_act_market_sale";
      
      protected const DRAGON_EYRIE:String = "dragon_pen_finished";
      
      protected const YMENUOFFSET:int = -95;
      
      private const MARKET_INDICATOR_OFFSET_X:int = 20;
      
      private const MARKET_INDICATOR_OFFSET_Y:int = -140;
      
      private const EXCEED_PLUS_SIGN:String = "999+";
      
      private const GIFT_COUNT_PLUS_LIMIT:int = 999;
      
      private const DEFAULT_SELL_LOCK_LEVEL:int = 7;
      
      protected var m_terrainTopLeft:ActionMultiButton;
      
      protected var m_terrainTopMiddle:ActionMultiButton;
      
      protected var m_terrainTopRight:ActionMultiButton;
      
      protected var m_walk:ActionMultiButton;
      
      protected var m_plow:ActionMultiButton;
      
      protected var m_topRight:ActionMultiButton;
      
      protected var m_bottomLeft:ActionMultiButton;
      
      protected var m_market:ActionButton;
      
      protected var m_gifts:ActionMultiButton;
      
      protected var m_mastery:ActionButton;
      
      protected var m_giftsCount:Sprite;
      
      protected var m_giftsDisplaying:Boolean = true;
      
      protected var m_giftsCountText:TextField;
      
      private var m_plowSuperAvatarIcon:SuperAvatarActionIcon;
      
      private var m_plantSuperAvatarIcon:SuperAvatarActionIcon;
      
      private var m_harvestSuperAvatarIcon:SuperAvatarActionIcon;
      
      private var m_marketIndicator:MarketIndicatorWindow;
      
      private var m_tempTopRightItems:Array;
      
      private var m_displayButtonMenusOnRollover:Boolean = true;
      
      private var m_displayInitAsToggled:Boolean = true;
      
      private var m_initialized:Boolean = false;
      
      private var m_locked:Boolean = false;
      
      private var m_notice:Sprite;
      
      private var m_mainWindow:IrelandInnovationMainWindow;
      
      public function ActionMenu()
      {
         var bottomLeftAsset:Class = null;
         var bottomLeftToolTip:String = null;
         this.m_tempTopRightItems = [];
         super();
         this.m_terrainTopLeft = new ActionMultiButton(EmbeddedArt.hud_act_walk,this.onGetTerrainTopLeftItems,this.YMENUOFFSET,true,true);
         this.m_terrainTopLeft.toolTip = "Walk";
         this.m_terrainTopLeft.addEventListener(MouseEvent.ROLL_OVER,this.onTerrainRollover,false,1);
         this.m_terrainTopLeft.visible = false;
         addChild(this.m_terrainTopLeft);
         this.m_terrainTopMiddle = new ActionMultiButton(EmbeddedArt.hud_act_move,this.onGetTerrainTopMiddleItems,this.YMENUOFFSET,true,true);
         this.m_terrainTopMiddle.toolTip = "Deco";
         this.m_terrainTopMiddle.addEventListener(MouseEvent.ROLL_OVER,this.onTerrainRollover,false,1);
         this.m_terrainTopMiddle.visible = false;
         this.m_terrainTopMiddle.x = 48;
         addChild(this.m_terrainTopMiddle);
         this.m_terrainTopRight = new ActionMultiButton(EmbeddedArt.hud_act_clear,this.onGetTerrainTopRightItems,this.YMENUOFFSET,true,true);
         this.m_terrainTopRight.toolTip = "Clear";
         this.m_terrainTopRight.addEventListener(MouseEvent.ROLL_OVER,this.onTerrainRollover,false,1);
         this.m_terrainTopRight.visible = false;
         this.m_terrainTopRight.x = 96;
         addChild(this.m_terrainTopRight);
         this.m_displayButtonMenusOnRollover = false;
         this.m_displayInitAsToggled = false;
         this.m_walk = new ActionMultiButton(EmbeddedArt.hud_act_walk,this.onGetWalkItems,this.YMENUOFFSET,this.m_displayInitAsToggled,this.m_displayButtonMenusOnRollover);
         this.m_walk.toolTip = ZLocUtils.t("FarmGame","Button_Walk");
         this.m_walk.addEventListener(MouseEvent.ROLL_OVER,this.onWalkRollover,false,1);
         addChild(this.m_walk);
         this.m_plow = new ActionMultiButton(EmbeddedArt.hud_act_plow,this.onGetPlowItems,this.YMENUOFFSET,this.m_displayInitAsToggled,this.m_displayButtonMenusOnRollover);
         this.m_plow.toolTip = ZLocUtils.t("FarmGame","Button_Plow");
         this.m_plow.addEventListener(MouseEvent.ROLL_OVER,this.onPlowRollover,false,1);
         this.m_plow.x = 48;
         addChild(this.m_plow);
         this.m_topRight = new ActionMultiButton(EmbeddedArt.hud_act_clear,this.onGetTopRightItems,this.YMENUOFFSET,this.m_displayInitAsToggled,this.m_displayButtonMenusOnRollover);
         this.m_topRight.toolTip = ZLocUtils.t("FarmGame","Button_Clear");
         this.m_topRight.x = 96;
         this.m_topRight.addEventListener(MouseEvent.ROLL_OVER,this.onTopRightRollover);
         addChild(this.m_topRight);
         if(ExchangeManager.getInstance().isInMainExperiment(ExchangeManager.TRADER_BUSHEL))
         {
            bottomLeftAsset = EmbeddedArt.hud_bushelTrader;
            bottomLeftToolTip = ZLocUtils.t("Dialogs","ActionMenu_bushelTrader");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_JUNGLE_HIDEAWAY))
         {
            bottomLeftAsset = EmbeddedArt.hud_junglehideaway;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_junglehideaway");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_TINMAN_FOUNTAIN))
         {
            bottomLeftAsset = EmbeddedArt.hud_tinmanfountain;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_tinmanfountain");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_AZURE_EMPORIUM))
         {
            bottomLeftAsset = EmbeddedArt.hud_azureemporium;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_azureemporium");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_HOLLYBRIGHT_PARK))
         {
            bottomLeftAsset = EmbeddedArt.hud_hollybrightpark;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_hollybrightpark");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_HORSE_CRAFTING))
         {
            bottomLeftAsset = EmbeddedArt.hud_horseCrafting;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_horseCrafting");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_SAVANNAHRESERVE))
         {
            bottomLeftAsset = EmbeddedArt.hud_savannahreserve;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_savannahreserve");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XTR_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xtr_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xtr_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XWI_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xwi_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xwi_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xjp_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xjp_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES_MS))
         {
            bottomLeftAsset = EmbeddedArt.hud_xjp_elitehorses_ms;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xjp_elitehorses_ms");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XJM_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xjm_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xjm_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XMO_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xmo_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xmo_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XBO_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xbo_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xbo_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XCH_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xch_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xch_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_APOTHECARY))
         {
            bottomLeftAsset = EmbeddedArt.hud_apothecary;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_apothecary");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_SWEET_SHOP))
         {
            bottomLeftAsset = EmbeddedArt.hud_sweetshop;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_sweetshop");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_YARN_BARN))
         {
            bottomLeftAsset = EmbeddedArt.hud_yarnbarn;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_yarnbarn");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_DAIRY_CRAFTING))
         {
            bottomLeftAsset = EmbeddedArt.hud_dairyCrafting;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_dairyCraft");
         }
         else if(ItemContestManager.inMainExperiment())
         {
            bottomLeftAsset = EmbeddedArt.hud_item_contests;
            bottomLeftToolTip = ZLocUtils.t("FarmGame","Button_Contests");
            Global.world.addEventListener(ItemContestManager.EVENTLISTENER_CONTEST_TYPE,this.contestNotice);
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XIN_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xin_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xin_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XHH_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xhh_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xhh_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XTI_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xti_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xti_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XUW_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xuw_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xuw_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XDW_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xdw_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xdw_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XFE_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xfe_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xfe_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XHA_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xha_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xha_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XFW_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xfw_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xfw_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XBR_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xbr_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xbr_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XTY_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xty_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xty_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XDV_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xdv_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xdv_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XCB_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xcb_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xcb_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XRU_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xru_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xru_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XNF_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xnf_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xnf_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XIS_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xis_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xis_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XHX_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xhx_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xhx_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XWX_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xwx_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xwx_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XCA_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xca_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xca_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XBL_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xbl_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xbl_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XRT_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xrt_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xrt_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XSU_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xsu_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xsu_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XCL_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xcl_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xcl_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XID_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xid_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xid_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XHF_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xhf_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xhf_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XWS_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xws_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xws_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XFS_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xfs_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xfs_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XMT_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xmt_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xmt_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XBB_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xbb_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xbb_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XDM_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xdm_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xdm_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XCD_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xcd_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xcd_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XAH_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xah_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xah_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XPU_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xpu_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xpu_elitehorses");
         }
         else if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_XYT_ELITEHORSES))
         {
            bottomLeftAsset = EmbeddedArt.hud_xyt_elitehorses;
            bottomLeftToolTip = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_xyt_elitehorses");
         }
         this.m_bottomLeft = new ActionMultiButton(bottomLeftAsset,this.onGetBottomLeftItems,this.YMENUOFFSET,this.m_displayInitAsToggled,this.m_displayButtonMenusOnRollover);
         this.m_bottomLeft.toolTip = bottomLeftToolTip;
         this.m_bottomLeft.addEventListener(MouseEvent.ROLL_OVER,this.onBottomLeftRollover,false,1);
         this.m_bottomLeft.y = 58;
         addChild(this.m_bottomLeft);
         this.m_market = new ActionButton(ZLocUtils.tiEmbeddedArt(this.MARKET_ICON_ASSET_NAME_NORMAL),"bottom");
         this.m_market.toolTip = ZLocUtils.t("FarmGame","Button_Market");
         this.m_market.x = 48;
         this.m_market.y = 58;
         this.m_market.addEventListener(MouseEvent.CLICK,this.onMarket);
         this.m_market.addEventListener(MouseEvent.ROLL_OVER,this.onMarketRollover);
         addChild(this.m_market);
         this.m_gifts = new ActionMultiButton(EmbeddedArt.hud_gift,this.onGetStorageItems,this.YMENUOFFSET,this.m_displayInitAsToggled,this.m_displayButtonMenusOnRollover);
         this.m_gifts.toolTip = ZLocUtils.t("FarmGame","Button_Gifts");
         this.m_gifts.addEventListener(MouseEvent.ROLL_OVER,this.onStorageRollover,false,1);
         this.m_gifts.x = 96;
         this.m_gifts.y = 58;
         addChild(this.m_gifts);
         this.initGiftCountText();
         Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,this.onUserChanged);
         this.m_initialized = true;
      }
      
      private function contestNotice(mulchInfo:Object) : void
      {
         if(this.m_notice == null)
         {
            this.m_notice = new Sprite();
            this.m_notice.addChild(new EmbeddedArt.contests_notification());
            this.m_notice.y = 58;
            this.m_bottomLeft.parent.addChild(this.m_notice);
         }
         else
         {
            this.m_notice.visible = true;
            this.m_bottomLeft.parent.addChild(this.m_notice);
         }
      }
      
      private function initGiftCountText() : void
      {
         var notif:Bitmap = null;
         var textFormat:TextFormat = null;
         var giftCountText:StrokeTextField = null;
         var giftCount:int = 0;
         if(this.m_giftsCount == null)
         {
            this.m_giftsCount = new Sprite();
         }
         if(!Global.worldManager.isVisiting() && this.m_giftsCountText == null)
         {
            notif = new EmbeddedArt.gift_notification();
            this.m_giftsCount.addChild(notif);
            textFormat = new TextFormat("Merkin2",10,16777215,false);
            textFormat.align = TextFormatAlign.CENTER;
            giftCountText = new StrokeTextField(2105376,0.8);
            giftCountText.toolTipText = "0";
            giftCountText.filters = [];
            giftCountText.autoSize = TextFieldAutoSize.CENTER;
            giftCountText.width = notif.width;
            giftCountText.embedFonts = true;
            giftCountText.x = notif.width / 2 - 1;
            giftCountText.y = -4;
            if(Global.player)
            {
               if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
               {
                  giftCount = int(Global.player.getGifts().length);
               }
               else
               {
                  giftCount = Global.player.getGiftCount();
               }
               this.m_giftsCount.visible = giftCount > 0;
               if(giftCount > this.GIFT_COUNT_PLUS_LIMIT)
               {
                  giftCountText.text = this.EXCEED_PLUS_SIGN;
               }
               else
               {
                  giftCountText.text = String(giftCount);
               }
               this.m_walk.updateItems();
               this.m_plow.updateItems();
            }
            giftCountText.defaultTextFormat = textFormat;
            this.m_giftsCountText = giftCountText;
            this.m_giftsCount.x = this.m_gifts.width - this.m_giftsCount.width / 2 - 37 + this.m_gifts.x;
            this.m_giftsCount.y = 2 + this.m_gifts.y;
            Utilities.toggleInputAndChildren(this.m_giftsCount,false);
            this.m_giftsCount.addChild(giftCountText);
            this.m_gifts.parent.addChild(this.m_giftsCount);
         }
      }
      
      private function refreshGiftCountText(giftCount:int) : void
      {
         if(this.m_giftsCount == null || this.m_giftsCountText == null)
         {
            this.initGiftCountText();
         }
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            giftCount = int(Global.player.getGifts().length);
         }
         if(!Global.worldManager.isVisiting())
         {
            if(giftCount > this.GIFT_COUNT_PLUS_LIMIT)
            {
               this.m_giftsCountText.text = this.EXCEED_PLUS_SIGN;
            }
            else
            {
               this.m_giftsCountText.text = String(giftCount);
            }
            this.m_giftsCount.visible = giftCount > 0;
         }
         else
         {
            this.m_giftsCount.visible = false;
         }
      }
      
      public function hideArrowOnAllButtons() : void
      {
         this.m_walk.setArrow(false);
         this.m_plow.setArrow(false);
         this.m_topRight.setArrow(false);
         this.m_bottomLeft.setArrow(false);
         this.m_market.setArrow(false);
         this.m_gifts.setArrow(false);
      }
      
      public function setMarketIconNormalVersion() : void
      {
         this.changeMarketIcon(this.MARKET_ICON_ASSET_NAME_NORMAL);
      }
      
      public function setMarketIconSaleVersion() : void
      {
         this.changeMarketIcon(this.MARKET_ICON_ASSET_NAME_SALE);
      }
      
      protected function changeMarketIcon(embedIconName:String) : void
      {
         var iconAssetClass:Class = ZLocUtils.tiEmbeddedArt(embedIconName);
         if(iconAssetClass != null)
         {
            this.m_market.setIcon(new iconAssetClass());
         }
      }
      
      public function showMarketIndicatorArrow() : void
      {
         if(null == this.m_marketIndicator)
         {
            this.m_marketIndicator = new MarketIndicatorWindow(this.removeMarketIndicatorArrow);
            this.m_marketIndicator.visible = true;
            this.m_marketIndicator.enabled = true;
            this.m_marketIndicator.x = this.MARKET_INDICATOR_OFFSET_X;
            this.m_marketIndicator.y = this.MARKET_INDICATOR_OFFSET_Y;
            addChild(this.m_marketIndicator);
         }
      }
      
      public function removeMarketIndicatorArrow() : void
      {
         if(this.m_marketIndicator != null)
         {
            if(this.m_marketIndicator.parent == this)
            {
               removeChild(this.m_marketIndicator);
            }
            this.m_marketIndicator = null;
         }
      }
      
      public function getWalkButton() : ActionButton
      {
         return this.m_walk;
      }
      
      public function getPlowButton() : ActionButton
      {
         return this.m_plow;
      }
      
      public function getSocialMissionButton() : ActionButton
      {
         return this.m_topRight;
      }
      
      public function getBottomLeftButton() : ActionMultiButton
      {
         return this.m_bottomLeft;
      }
      
      public function refresh() : void
      {
         this.onUserChanged(null);
         this.resetMenus();
      }
      
      protected function onUserChanged(event:Event) : void
      {
         var giftCount:int = 0;
         if(Global.player)
         {
            if(!Global.worldManager.isVisiting())
            {
               if(this.m_giftsDisplaying)
               {
                  if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
                  {
                     giftCount = int(Global.player.getGifts().length);
                  }
                  else
                  {
                     giftCount = Global.player.getGiftCount();
                  }
               }
               else
               {
                  giftCount = Global.player.getInventoryUsage();
               }
               if(giftCount > this.GIFT_COUNT_PLUS_LIMIT)
               {
                  this.m_giftsCountText.text = this.EXCEED_PLUS_SIGN;
               }
               else
               {
                  this.m_giftsCountText.text = String(giftCount);
               }
               this.m_giftsCount.visible = giftCount > 0;
            }
            else if(Boolean(this.m_giftsCount) && this.m_giftsCount.visible)
            {
               this.m_giftsCount.visible = false;
            }
            this.m_topRight.updateItems(true);
            this.m_walk.updateItems();
            this.m_plow.updateItems();
            this.m_gifts.updateItems();
            this.m_bottomLeft.updateItems();
         }
      }
      
      private function resetMenus() : void
      {
         var resetMode:Boolean = true;
         this.m_topRight.showMenu(resetMode);
         this.m_topRight.hideMenu();
         this.m_walk.showMenu(resetMode);
         this.m_walk.hideMenu();
         this.m_plow.showMenu(resetMode);
         this.m_plow.hideMenu();
         this.refreshGiftboxIcon();
         this.m_bottomLeft.showMenu(resetMode);
         this.m_bottomLeft.hideMenu();
      }
      
      public function visitMode(visit:Boolean) : void
      {
         this.resetMenus();
         if(visit && this.contains(this.m_plow) && this.contains(this.m_topRight) && this.contains(this.m_market) && this.contains(this.m_gifts))
         {
            this.m_market.visible = false;
            this.m_gifts.visible = false;
            if(Boolean(this.m_giftsCount) && this.m_giftsCount.visible)
            {
               this.m_giftsCount.visible = false;
            }
            this.m_topRight.visible = false;
            this.m_plow.visible = false;
            this.m_walk.toggle();
         }
         if(!visit)
         {
            this.m_market.visible = true;
            this.m_gifts.visible = true;
            this.m_topRight.visible = true;
            this.m_plow.visible = true;
            this.refreshGiftCountText(Global.player.getGiftCount());
         }
      }
      
      private function onGetWalkItems() : Array
      {
         var walkText:String = null;
         var decoText:String = null;
         var clearToolName:String = null;
         var decoModeText:String = null;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var items:Array = [];
         if(!this.m_locked)
         {
            if(Global.worldManager.isVisiting() == false)
            {
               if(TerrainUtil.isDevTerrainMappingCreationToolAvailable() && Global.world.terrainMap is UDTMap)
               {
                  items.push(UDTManager.actionMenuItem);
               }
               if(Global.player.level >= Global.farmGameSettingsManager.getAttribute("socialMissionUnlockLevel",20))
               {
                  clearToolName = ZLocUtils.t("FarmGame","Button_Clear");
                  items.push({
                     "toolTip":clearToolName,
                     "text":clearToolName,
                     "icon":EmbeddedArt.hud_act_clear,
                     "onClick":this.onClearMultiMenu
                  });
               }
               if(Global.player.level >= Global.farmGameSettingsManager.getInt("sellLockLevel",this.DEFAULT_SELL_LOCK_LEVEL))
               {
                  decoModeText = ZLocUtils.t("FarmGame","Button_DecoratorMode");
                  items.push({
                     "toolTip":decoModeText,
                     "text":decoModeText,
                     "icon":EmbeddedArt.decorator_mode,
                     "onClick":this.onDesignMode
                  });
               }
               decoText = ZLocUtils.t("FarmGame","Button_Deco");
               items.push({
                  "toolTip":decoText,
                  "text":decoText,
                  "icon":EmbeddedArt.hud_act_move,
                  "onClick":this.onMove
               });
            }
            walkText = ZLocUtils.t("FarmGame","Button_Walk");
            items.push({
               "toolTip":walkText,
               "text":walkText,
               "icon":EmbeddedArt.hud_act_walk,
               "onClick":this.onWalk
            });
         }
         return items;
      }
      
      public function getVillageGiftMenuButton() : ActionMultiButton
      {
         var giftButton:ActionMultiButton = new ActionMultiButton(EmbeddedArt.village_hud_gift,this.onGetVillageHudItems,this.YMENUOFFSET,this.m_displayInitAsToggled,this.m_displayButtonMenusOnRollover);
         giftButton.toolTip = ZLocUtils.t("FarmGame","Button_Gifts");
         giftButton.addEventListener(MouseEvent.ROLL_OVER,this.onStorageRollover,false,1);
         return giftButton;
      }
      
      private function onGetVillageHudItems() : Array
      {
         var items:Array = [];
         if(!this.m_locked)
         {
            items.push({
               "icon":EmbeddedArt.hud_search,
               "onClick":this.onSearch,
               "toolTip":ZLocUtils.t("FarmGame","Search"),
               "text":ZLocUtils.t("FarmGame","Search")
            });
            if(UI.areGiftsLocked())
            {
               items.push({
                  "icon":EmbeddedArt.hud_gift_locked,
                  "onClick":this.onGifts,
                  "toolTip":ZLocUtils.t("FarmGame","Gifts"),
                  "text":ZLocUtils.t("FarmGame","Gifts")
               });
            }
            else if(Global.experimentManager != null && Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2 && Global.player != null && Global.farmGameSettingsManager.getInt("maxGiftLimit") != 0 && Global.player.getGifts().length / Global.farmGameSettingsManager.getInt("maxGiftLimit") * 100 > GiftBoxWindow.PRELIM_WARNING_VALUE)
            {
               items.push({
                  "icon":EmbeddedArt.hud_gift_warning,
                  "onClick":this.onGifts,
                  "toolTip":ZLocUtils.t("FarmGame","Gifts"),
                  "text":ZLocUtils.t("FarmGame","Gifts")
               });
            }
            else
            {
               items.push({
                  "icon":EmbeddedArt.hud_gift,
                  "onClick":this.onGifts,
                  "toolTip":ZLocUtils.t("FarmGame","Gifts"),
                  "text":ZLocUtils.t("FarmGame","Gifts")
               });
            }
         }
         return items;
      }
      
      private function onGetStorageItems() : Array
      {
         var toolShed:FarmItem = null;
         var canSeeStorage:Boolean = false;
         var giftCount:int = 0;
         var items:Array = [];
         if(!this.m_locked)
         {
            items.push({
               "icon":EmbeddedArt.hud_search,
               "onClick":this.onSearch,
               "toolTip":ZLocUtils.t("FarmGame","Search"),
               "text":ZLocUtils.t("FarmGame","Search")
            });
            toolShed = Global.farmGameSettingsManager.getFarmItemByName("toolshed");
            canSeeStorage = int(toolShed.requiredLevel) <= Global.player.level;
            if(canSeeStorage)
            {
               items.push({
                  "icon":EmbeddedArt.hud_storage,
                  "onClick":this.onInventory,
                  "toolTip":ZLocUtils.t("FarmGame","Storage"),
                  "text":ZLocUtils.t("FarmGame","Storage")
               });
            }
            if(UI.areGiftsLocked())
            {
               items.push({
                  "icon":EmbeddedArt.hud_gift_locked,
                  "onClick":this.onGifts,
                  "toolTip":ZLocUtils.t("FarmGame","Gifts"),
                  "text":ZLocUtils.t("FarmGame","Gifts")
               });
            }
            else if(Global.experimentManager != null && Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2 && Global.player != null && Global.farmGameSettingsManager.getInt("maxGiftLimit") != 0 && Global.player.getGifts().length / Global.farmGameSettingsManager.getInt("maxGiftLimit") * 100 > GiftBoxWindow.PRELIM_WARNING_VALUE)
            {
               items.push({
                  "icon":EmbeddedArt.hud_gift_warning,
                  "onClick":this.onGifts,
                  "toolTip":ZLocUtils.t("FarmGame","Gifts"),
                  "text":ZLocUtils.t("FarmGame","Gifts")
               });
            }
            else
            {
               items.push({
                  "icon":EmbeddedArt.hud_gift,
                  "onClick":this.onGifts,
                  "toolTip":ZLocUtils.t("FarmGame","Gifts"),
                  "text":ZLocUtils.t("FarmGame","Gifts")
               });
            }
            if(!this.m_displayButtonMenusOnRollover)
            {
               this.untoggleAll();
               if(this.m_giftsCountText != null)
               {
                  if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
                  {
                     giftCount = int(Global.player.getGifts().length);
                  }
                  else
                  {
                     giftCount = Global.player.getGiftCount();
                  }
                  if(giftCount > this.GIFT_COUNT_PLUS_LIMIT)
                  {
                     this.m_giftsCountText.text = this.EXCEED_PLUS_SIGN;
                  }
                  else
                  {
                     this.m_giftsCountText.text = String(giftCount);
                  }
                  if(!Global.worldManager.isVisiting())
                  {
                     this.m_giftsCount.visible = giftCount > 0;
                  }
               }
            }
            else
            {
               this.m_walk.untoggle();
               this.m_plow.untoggle();
               this.m_topRight.untoggle();
               this.m_bottomLeft.untoggle();
            }
         }
         return items;
      }
      
      private function highlight(button:ActionMultiButton) : void
      {
         button.highlight();
         this.unHighlightAll(button);
      }
      
      private function unHighlightAll(exception:ActionMultiButton = null) : void
      {
         if(exception != this.m_walk)
         {
            this.m_walk.unHighlight();
         }
         if(exception != this.m_plow)
         {
            this.m_plow.unHighlight();
         }
         if(exception != this.m_topRight)
         {
            this.m_topRight.unHighlight();
         }
         if(exception != this.m_gifts)
         {
            this.m_gifts.unHighlight();
         }
         if(exception != this.m_bottomLeft)
         {
            this.m_bottomLeft.unHighlight();
         }
      }
      
      private function toggle(button:ActionMultiButton) : void
      {
         button.toggle();
         this.untoggleAll(button);
      }
      
      private function untoggleAll(exception:ActionMultiButton = null) : void
      {
         if(exception != this.m_walk)
         {
            this.m_terrainTopLeft.untoggle();
            this.m_terrainTopMiddle.untoggle();
            this.m_terrainTopRight.untoggle();
            this.m_walk.untoggle();
         }
         if(exception != this.m_plow)
         {
            this.m_plow.untoggle();
         }
         if(exception != this.m_topRight)
         {
            this.m_topRight.untoggle();
         }
         if(exception != this.m_gifts)
         {
            this.m_gifts.untoggle();
         }
         if(exception != this.m_bottomLeft)
         {
            this.m_bottomLeft.untoggle();
         }
      }
      
      public function refreshGiftboxIcon() : void
      {
         this.m_gifts.showMenu(true);
         this.m_gifts.hideMenu();
      }
      
      public function terrainMode(terrain:Boolean) : void
      {
         if(!terrain)
         {
            if(this.m_walk)
            {
               this.m_walk.updateItems(true);
            }
            this.refreshGiftCountText(Global.player.getGiftCount());
         }
         if(this.m_terrainTopLeft)
         {
            this.m_terrainTopLeft.visible = terrain;
         }
         if(this.m_terrainTopMiddle)
         {
            this.m_terrainTopMiddle.visible = terrain;
         }
         if(this.m_terrainTopRight)
         {
            this.m_terrainTopRight.visible = terrain;
         }
         if(this.m_walk)
         {
            this.m_walk.visible = !terrain;
         }
         if(this.m_plow)
         {
            this.m_plow.visible = !terrain;
         }
         if(this.m_topRight)
         {
            this.m_topRight.visible = !terrain;
         }
         if(this.m_bottomLeft)
         {
            this.m_bottomLeft.visible = !terrain;
         }
         if(this.m_market)
         {
            this.m_market.visible = !terrain;
         }
         if(this.m_gifts)
         {
            this.m_gifts.visible = !terrain;
         }
         if(this.m_giftsCount)
         {
            this.m_giftsCount.visible = !terrain;
         }
      }
      
      private function onGetTerrainTopLeftItems() : Array
      {
         var items:Array = [];
         items.push({
            "text":"Walk",
            "icon":EmbeddedArt.hud_act_walk,
            "onClick":this.onTerrainTopLeft
         });
         return items;
      }
      
      private function onGetTerrainTopMiddleItems() : Array
      {
         var items:Array = [];
         items.push({
            "text":"Deco",
            "icon":EmbeddedArt.hud_act_move,
            "onClick":this.onTerrainTopMiddle
         });
         return items;
      }
      
      private function onGetTerrainTopRightItems() : Array
      {
         var items:Array = [];
         items.push({
            "text":"Clear",
            "icon":EmbeddedArt.hud_act_clear,
            "onClick":this.onTerrainTopRight
         });
         return items;
      }
      
      private function onTerrainTopLeft(e:MouseEvent = null) : void
      {
         UDTManager.enterTerrainEditor(UDTManager.DEFAULT);
      }
      
      private function onTerrainTopMiddle(e:MouseEvent = null) : void
      {
         UDTManager.enterTerrainEditor(UDTManager.MOVE);
      }
      
      private function onTerrainTopRight(e:MouseEvent = null) : void
      {
         UDTManager.enterTerrainEditor(UDTManager.CLEAR);
      }
      
      private function onTerrainRollover(e:MouseEvent = null) : void
      {
         this.untoggleAll();
      }
      
      public function onWalk(e:MouseEvent = null) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         if(Global.selectedAvatar != null)
         {
            if(Global.worldManager.isVisiting() == false)
            {
               Global.world.addGameMode(new GMDefault(),true);
            }
            else
            {
               Global.world.addGameMode(VisitorManager.getInstance().getVisitGM(),true);
            }
         }
         dispatchEvent(new ActionMenuEvent(ActionMenuEvent.ONWALK));
         PetManager.getInstance().resetRescuePet();
      }
      
      public function setDefaultGameMode() : void
      {
         if(Global.selectedAvatar != null)
         {
            if(!Global.worldManager.isVisiting())
            {
               Global.world.addGameMode(new GMDefault(),true);
               this.resetMenus();
            }
            else
            {
               Global.world.addGameMode(VisitorManager.getInstance().getVisitGM(),true);
            }
         }
         if(Boolean(Global.ui.bushelReportWindow) && BushelReportWindow.isWindowOpen())
         {
            Global.ui.bushelReportWindow.close();
         }
      }
      
      private function onWalkRollover(e:MouseEvent = null) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.highlight(this.m_walk);
         }
         else
         {
            this.m_walk.toggle();
            this.m_plow.untoggle();
            this.m_topRight.untoggle();
            this.m_gifts.untoggle();
            this.m_bottomLeft.untoggle();
         }
      }
      
      protected function onSuperPlow(item:Object) : void
      {
         Global.world.addGameMode(new GMSuperAvatarPlow(),true);
      }
      
      protected function onSuperPlant(item:Object) : void
      {
         UI.displayMarketDialog("superAvatar","seed",UI.MARKET_LAUNCH_REFERENCE_SUPER_AVATAR,"seeds",null,null,null,null,-1,item.terrainCodes);
      }
      
      protected function onSuperHarvest(item:Object) : void
      {
         Global.world.addGameMode(new GMSuperAvatarHarvest(),true);
      }
      
      protected function onHarvester(item:Object) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         CraftingUI.fuelForGoodsToaster();
         var equipment:Harvester = Global.world.getEquipment(Harvester,item.terrainCodes) as Harvester;
         if(equipment == null)
         {
            equipment = Global.world.getEquipment(RotatableHarvester,item.terrainCodes) as Harvester;
         }
         if(TurboPPHManager.getInstance().turboSelected)
         {
            Global.world.addGameMode(new GMHarvesterAll(equipment),true);
         }
         else
         {
            Global.world.addGameMode(new GMHarvester(equipment),true);
         }
      }
      
      protected function onBuyHarvester(item:Object) : void
      {
         var totHarvester:Array = null;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var availableHarvesters:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("Harvester");
         var rotHarvester:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("RotatableHarvester");
         if(rotHarvester != null && rotHarvester.length > 0 && Global.worldManager.currentWorldType == "twenties")
         {
            totHarvester = rotHarvester.concat(availableHarvesters);
         }
         else
         {
            totHarvester = availableHarvesters.concat(rotHarvester);
         }
         totHarvester = this.filterItemArrayByTerrainCode(totHarvester,item.terrainCodes);
         UI.displayMiniMarketDialog(totHarvester,"actionMenuTractorBuy","vehicle");
      }
      
      public function onIrrigationSprinkler(item:Object) : void
      {
         var equipment:IrrigationSprinkler = Global.world.getEquipment(IrrigationSprinkler) as IrrigationSprinkler;
         Global.world.addGameMode(new GMIrrigationSprinkler(equipment));
      }
      
      public function onBuyIrrigationSprinkler(item:Object) : void
      {
         var availableHarvesters:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("IrrigationSprinkler");
         UI.displayMiniMarketDialog(availableHarvesters,"actionMenuIrrigationSprinklerrBuy","vehicle");
      }
      
      protected function onOrchardHarvester(item:Object) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var equipment:OrchardHarvester = Global.world.getEquipment(OrchardHarvester,item.terrainCodes) as OrchardHarvester;
         if(equipment == null)
         {
            equipment = Global.world.getEquipment(RotatableOrchardHarvester,item.terrainCodes) as OrchardHarvester;
         }
         equipment.showSelectPatternWindow(Equipment.SOURCE_ACTION_MENU);
      }
      
      protected function onBuyOrchardHarvester(item:Object) : void
      {
         var totOrchardHarvester:Array = null;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var availableHarvesters:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("OrchardHarvester");
         var rotOrchardHarvester:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("RotatableOrchardHarvester");
         if(rotOrchardHarvester != null && rotOrchardHarvester.length > 0 && Global.worldManager.currentWorldType == "twenties")
         {
            totOrchardHarvester = rotOrchardHarvester.concat(availableHarvesters);
         }
         else
         {
            totOrchardHarvester = availableHarvesters.concat(rotOrchardHarvester);
         }
         UI.displayMiniMarketDialog(totOrchardHarvester,"actionMenuOrchardHarvesterBuy","vehicle");
      }
      
      private function filterItemArrayByTerrainCode(items:Array, terrainCodesAllowed:Array) : Array
      {
         var itemName:String = null;
         var item:FarmItem = null;
         var terrainCodes:Array = null;
         var code:int = 0;
         var filteredArray:Array = new Array();
         for each(itemName in items)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(item)
            {
               terrainCodes = item.getTerrainCodes();
               for each(code in terrainCodes)
               {
                  if(terrainCodesAllowed.hasOwnProperty(code))
                  {
                     filteredArray.push(itemName);
                     break;
                  }
               }
            }
         }
         return filteredArray;
      }
      
      protected function onSeeder(item:Object) : void
      {
         var subType:String = null;
         var subSubType:String = null;
         var sortBy:String = null;
         var sortDirection:String = null;
         var page:int = 0;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UX_COMBINE_MARKET_SEARCH) == 2)
         {
            UI.displaySeedSelectionMiniMarketDialog(item.terrainCodes,UI.MARKET_LAUNCH_REFERENCE_SEEDER);
         }
         else if(MarketWindow.previousType == "seed" && MarketWindow.previousSubType != "tree")
         {
            subType = MarketWindow.previousSubType;
            subSubType = MarketWindow.previousSubSubType;
            sortBy = MarketWindow.previousSortBy;
            sortDirection = MarketWindow.previousSortDirection;
            page = MarketWindow.previousPage;
            UI.displayMarketDialog("actionMenuSeeder","seed",UI.MARKET_LAUNCH_REFERENCE_SEEDER,subType,null,subSubType,sortBy,sortDirection,page,item.terrainCodes);
         }
         else
         {
            UI.displayMarketDialog("actionMenuSeeder","seed",UI.MARKET_LAUNCH_REFERENCE_SEEDER,"seeds",null,null,null,null,-1,item.terrainCodes);
         }
      }
      
      protected function onBuySeeder(item:Object) : void
      {
         var totSeeders:Array = null;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var availableSeeders:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("Seeder");
         var rotSeeder:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("RotatableSeeder");
         if(rotSeeder != null && rotSeeder.length > 0 && Global.worldManager.currentWorldType == "twenties")
         {
            totSeeders = rotSeeder.concat(availableSeeders);
         }
         else
         {
            totSeeders = availableSeeders.concat(rotSeeder);
         }
         totSeeders = this.filterItemArrayByTerrainCode(totSeeders,item.terrainCodes);
         UI.displayMiniMarketDialog(totSeeders,"actionMenuTractorBuy","vehicle");
      }
      
      protected function onAirplane() : void
      {
         var message:String = null;
         var dialog:GenericPopup = null;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         CraftingUI.fuelForGoodsToaster();
         var plane:Airplane = null;
         var planes:Array = Global.world.getObjectsByClass(Airplane);
         if(planes.length > 0)
         {
            plane = planes[0];
         }
         var gameModeAddedSuccess:Boolean = Global.world.addGameMode(new GMAirplaneFly(plane));
         if(gameModeAddedSuccess == false)
         {
            message = ZLocUtils.t("Dialogs","InstantGrow_OnlyOnePlaneAtATime");
            dialog = new GenericPopup(message,GenericPopup.TYPE_OK);
            UI.displayPopup(dialog);
         }
      }
      
      protected function onBuyAirplane() : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var availableAirplanes:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("Airplane");
         UI.displayMiniMarketDialog(availableAirplanes,"actionMenuTractorBuy","vehicle");
      }
      
      private function onCombine(item:Object) : void
      {
         var subType:String = null;
         var subSubType:String = null;
         var sortBy:String = null;
         var sortDirection:String = null;
         var page:int = 0;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         if(Global.player.getSeenFlag(CombineOnboardingWindow.SEEN_FLAG) == false)
         {
            UI.displayPopup(new CombineOnboardingWindow(),true);
         }
         CraftingUI.fuelForGoodsToaster();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UX_COMBINE_MARKET_SEARCH) == 2)
         {
            UI.displaySeedSelectionMiniMarketDialog(item.terrainCodes,UI.MARKET_LAUNCH_REFERENCE_COMBINE);
         }
         else if(MarketWindow.previousType == "seed" && MarketWindow.previousSubType != "tree")
         {
            subType = MarketWindow.previousSubType;
            subSubType = MarketWindow.previousSubSubType;
            sortBy = MarketWindow.previousSortBy;
            sortDirection = MarketWindow.previousSortDirection;
            page = MarketWindow.previousPage;
            UI.displayMarketDialog("actionMenuCombine","seed",UI.MARKET_LAUNCH_REFERENCE_COMBINE,subType,null,subSubType,sortBy,sortDirection,page,item.terrainCodes);
         }
         else
         {
            UI.displayMarketDialog("actionMenuCombine","seed",UI.MARKET_LAUNCH_REFERENCE_COMBINE,"seeds",null,null,null,null,-1,item.terrainCodes);
         }
      }
      
      private function onBuyCombine(item:Object) : void
      {
         var totCombine:Array = null;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var availableCombines:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("Combine");
         var rotCombine:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("RotatableCombine");
         if(rotCombine != null && rotCombine.length > 0 && Global.worldManager.currentWorldType == "twenties")
         {
            totCombine = rotCombine.concat(availableCombines);
         }
         else
         {
            totCombine = availableCombines.concat(rotCombine);
         }
         totCombine = this.filterItemArrayByTerrainCode(totCombine,item.terrainCodes);
         UI.displayMiniMarketDialog(totCombine,"actionMenuTractorBuy","vehicle");
      }
      
      private function onGetPlowItems() : Array
      {
         var tractor:FarmItem = null;
         var canBuyTractor:Boolean = false;
         var plotRemover:FarmItem = null;
         var canBuyPlotRemover:Boolean = false;
         var seeder:FarmItem = null;
         var canBuySeeder:Boolean = false;
         var harvester:FarmItem = null;
         var canBuyHarvester:Boolean = false;
         var combine:FarmItem = null;
         var canBuyCombine:Boolean = false;
         var orchardHarvester:FarmItem = null;
         var canBuyOrchardHarvester:Boolean = false;
         var worldConfig:Object = null;
         var hudSkinConfig:HUDSkinConfig = null;
         var menu:HUDSkinConfigMenu = null;
         var totalColumns:int = 0;
         var rowIndex:int = 0;
         var defaultTerrainAssetTag:String = null;
         var defaultTerrainNames:Array = null;
         var terrainAssetTag:String = null;
         var terrainNames:Array = null;
         var terrainCodes:Array = null;
         var colIndex:int = 0;
         var defaultPlowItem:Object = null;
         var plowItems:Array = null;
         var tmpObject:Object = null;
         var equipment:Equipment = null;
         var rotatableEquipment:Equipment = null;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var items:Array = [];
         if(!this.m_locked)
         {
            tractor = Global.farmGameSettingsManager.getFarmItemByName("tractor");
            canBuyTractor = int(tractor.requiredLevel) <= Global.player.level;
            plotRemover = Global.farmGameSettingsManager.getFarmItemByName("xsa_treasureplotremover");
            canBuyPlotRemover = int(plotRemover.requiredLevel) <= Global.player.level && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_TREASURETIDES) == 1;
            seeder = Global.farmGameSettingsManager.getFarmItemByName("seeder");
            canBuySeeder = int(seeder.requiredLevel) <= Global.player.level;
            harvester = Global.farmGameSettingsManager.getFarmItemByName("harvester");
            canBuyHarvester = int(harvester.requiredLevel) <= Global.player.level;
            combine = Global.farmGameSettingsManager.getFarmItemByName("allpurposetractorhotrod");
            canBuyCombine = false;
            if(combine)
            {
               canBuyCombine = int(combine.requiredLevel) <= Global.player.level;
            }
            orchardHarvester = Global.farmGameSettingsManager.getFarmItemByName("orchardharvester");
            canBuyOrchardHarvester = orchardHarvester.requiredLevel <= Global.player.level;
            worldConfig = Global.worldSettingsManager.getConfigByWorld(Global.worldManager.currentWorldType);
            hudSkinConfig = null;
            menu = null;
            if(Boolean(worldConfig) && Boolean(worldConfig.hudSkinConfig))
            {
               hudSkinConfig = worldConfig.hudSkinConfig as HUDSkinConfig;
               if(hudSkinConfig)
               {
                  menu = hudSkinConfig.getMenuByName("plowItems");
               }
            }
            totalColumns = 1;
            if(menu)
            {
               totalColumns = menu.totalColumns();
            }
            rowIndex = 0;
            defaultTerrainAssetTag = "ground";
            defaultTerrainNames = ["default","land","earth","water","zen","snow","turtle","dream","borabora"];
            terrainAssetTag = defaultTerrainAssetTag;
            terrainNames = null;
            terrainCodes = null;
            for(colIndex = 0; colIndex < totalColumns; colIndex++)
            {
               plowItems = [];
               rowIndex = 0;
               if(menu)
               {
                  terrainAssetTag = menu.getColumnAssetTag(colIndex);
                  terrainNames = menu.getColumnTerrainNames(colIndex);
               }
               else
               {
                  terrainAssetTag = defaultTerrainAssetTag;
                  terrainNames = defaultTerrainNames;
               }
               terrainCodes = Global.farmGameSettingsManager.convertArrayTerrainNamesToCodes(terrainNames);
               if(Global.worldManager.isVisiting() == false)
               {
                  equipment = Global.world.getEquipment(Tractor,terrainCodes);
                  rotatableEquipment = Global.world.getEquipment(RotatableTractor,terrainCodes);
                  if(Global.player.getNumSuperAvatarActions(HarvestableResource.RESOURCE_ACTION_CLEAR) > 0)
                  {
                     this.m_plowSuperAvatarIcon.showIcon(HarvestableResource.RESOURCE_ACTION_CLEAR);
                     plowItems.push({
                        "text":ZLocUtils.t("FarmGame","Button_SuperPlow"),
                        "sprite":this.m_plowSuperAvatarIcon,
                        "onClick":this.onSuperPlow
                     });
                  }
                  else if(canBuyTractor)
                  {
                     if(equipment != null && equipment.isPlaced() || rotatableEquipment != null && rotatableEquipment.isPlaced())
                     {
                        plowItems.push({
                           "text":ZLocUtils.t("FarmGame","Button_Tractor"),
                           "icon":EmbeddedArt["hud_act_tractor_" + terrainAssetTag],
                           "onClick":this.onTractor
                        });
                     }
                     else
                     {
                        plowItems.push({
                           "toolTip":ZLocUtils.t("FarmGame","Button_Tractor"),
                           "text":ZLocUtils.t("FarmGame","Button_BuyTractor"),
                           "icon":EmbeddedArt["hud_act_tractor_buy_" + terrainAssetTag],
                           "onClick":this.onBuyTractor,
                           "clickOnly":true
                        });
                     }
                  }
                  if(canBuyPlotRemover)
                  {
                     equipment = Global.world.getEquipment(PlotRemover,terrainCodes);
                     rotatableEquipment = Global.world.getEquipment(RotatablePlotRemover,terrainCodes);
                     if(equipment != null && equipment.isPlaced() || rotatableEquipment != null && rotatableEquipment.isPlaced())
                     {
                        plowItems.push({
                           "text":ZLocUtils.t("FarmGame","Button_PlotRemover"),
                           "icon":EmbeddedArt["hud_act_plotremover_" + terrainAssetTag],
                           "onClick":this.onPlotRemover
                        });
                     }
                     else
                     {
                        plowItems.push({
                           "toolTip":ZLocUtils.t("FarmGame","Button_PlotRemover"),
                           "text":ZLocUtils.t("FarmGame","Button_BuyPlotRemover"),
                           "icon":EmbeddedArt["hud_act_plotremover_buy_" + terrainAssetTag],
                           "onClick":this.onBuyPlotRemover,
                           "clickOnly":true
                        });
                     }
                  }
                  if(Global.player.getNumSuperAvatarActions(HarvestableResource.RESOURCE_ACTION_PLANT) > 0)
                  {
                     this.m_plantSuperAvatarIcon.showIcon(HarvestableResource.RESOURCE_ACTION_PLANT);
                     plowItems.push({
                        "text":ZLocUtils.t("FarmGame","Button_SuperPlant"),
                        "sprite":this.m_plantSuperAvatarIcon,
                        "onClick":this.onSuperPlant
                     });
                  }
                  else if(canBuySeeder)
                  {
                     equipment = Global.world.getEquipment(Seeder,terrainCodes);
                     rotatableEquipment = Global.world.getEquipment(RotatableSeeder,terrainCodes);
                     if(equipment != null && equipment.isPlaced() || rotatableEquipment != null && rotatableEquipment.isPlaced())
                     {
                        plowItems.push({
                           "text":ZLocUtils.t("FarmGame","Button_Seeder"),
                           "icon":EmbeddedArt["hud_act_seeder_" + terrainAssetTag],
                           "onClick":this.onSeeder
                        });
                     }
                     else
                     {
                        plowItems.push({
                           "toolTip":ZLocUtils.t("FarmGame","Button_Seeder"),
                           "text":ZLocUtils.t("FarmGame","Button_BuySeeder"),
                           "icon":EmbeddedArt["hud_act_seeder_buy_" + terrainAssetTag],
                           "onClick":this.onBuySeeder,
                           "clickOnly":true
                        });
                     }
                  }
                  if(Global.player.getNumSuperAvatarActions(HarvestableResource.RESOURCE_ACTION_HARVEST) > 0)
                  {
                     this.m_harvestSuperAvatarIcon.showIcon(HarvestableResource.RESOURCE_ACTION_HARVEST);
                     plowItems.push({
                        "text":ZLocUtils.t("FarmGame","Button_SuperHarvest"),
                        "sprite":this.m_harvestSuperAvatarIcon,
                        "onClick":this.onSuperHarvest
                     });
                  }
                  else if(canBuyHarvester)
                  {
                     equipment = Global.world.getEquipment(Harvester,terrainCodes);
                     rotatableEquipment = Global.world.getEquipment(RotatableHarvester,terrainCodes);
                     if(equipment != null && equipment.isPlaced() || rotatableEquipment != null && rotatableEquipment.isPlaced())
                     {
                        plowItems.push({
                           "text":ZLocUtils.t("FarmGame","Button_Harvester"),
                           "icon":EmbeddedArt["hud_act_harvester_" + terrainAssetTag],
                           "onClick":this.onHarvester
                        });
                     }
                     else
                     {
                        plowItems.push({
                           "toolTip":ZLocUtils.t("FarmGame","Button_Harvester"),
                           "text":ZLocUtils.t("FarmGame","Button_BuyHarvester"),
                           "icon":EmbeddedArt["hud_act_harvester_buy_" + terrainAssetTag],
                           "onClick":this.onBuyHarvester,
                           "clickOnly":true
                        });
                     }
                  }
                  if(canBuyCombine)
                  {
                     equipment = Global.world.getEquipment(Combine,terrainCodes);
                     rotatableEquipment = Global.world.getEquipment(RotatableCombine,terrainCodes);
                     if(equipment != null && equipment.isPlaced() || rotatableEquipment != null && rotatableEquipment.isPlaced())
                     {
                        plowItems.push({
                           "text":ZLocUtils.t("FarmGame","Button_Combine"),
                           "icon":EmbeddedArt["hud_act_combine_" + terrainAssetTag],
                           "onClick":this.onCombine
                        });
                     }
                     else
                     {
                        plowItems.push({
                           "toolTip":ZLocUtils.t("FarmGame","Button_Combine"),
                           "text":ZLocUtils.t("FarmGame","Button_BuyCombine"),
                           "icon":EmbeddedArt["hud_act_combine_buy_" + terrainAssetTag],
                           "onClick":this.onBuyCombine,
                           "clickOnly":true
                        });
                     }
                  }
                  if(canBuyOrchardHarvester)
                  {
                     equipment = Global.world.getEquipment(OrchardHarvester);
                     rotatableEquipment = Global.world.getEquipment(RotatableOrchardHarvester,terrainCodes);
                     if(equipment != null && equipment.isPlaced() || rotatableEquipment != null && rotatableEquipment.isPlaced())
                     {
                        plowItems.push({
                           "text":ZLocUtils.t("FarmGame","Button_OrchardHarvester"),
                           "icon":EmbeddedArt["hud_act_orchardharvester_" + terrainAssetTag],
                           "onClick":this.onOrchardHarvester
                        });
                     }
                     else
                     {
                        plowItems.push({
                           "toolTip":ZLocUtils.t("FarmGame","Button_OrchardHarvester"),
                           "text":ZLocUtils.t("FarmGame","Button_BuyOrchardHarvester"),
                           "icon":EmbeddedArt["hud_act_orchardharvester_buy_" + terrainAssetTag],
                           "onClick":this.onBuyOrchardHarvester,
                           "clickOnly":true
                        });
                     }
                  }
                  if(IrrigationManager.instance.isFeatureEnabled())
                  {
                     equipment = Global.world.getEquipment(IrrigationSprinkler);
                     if(Boolean(equipment) && equipment.isPlaced())
                     {
                        plowItems.push({
                           "text":ZLocUtils.t("FarmGame","Button_IrrigationSprinkler"),
                           "icon":EmbeddedArt.hud_act_irrigationsprinkler_ground,
                           "onClick":this.onIrrigationSprinkler
                        });
                     }
                     else
                     {
                        plowItems.push({
                           "toolTip":ZLocUtils.t("FarmGame","Button_IrrigationSprinkler"),
                           "text":ZLocUtils.t("FarmGame","Button_IrrigationSprinkler"),
                           "icon":EmbeddedArt.hud_act_irrigationsprinkler_buy_ground,
                           "onClick":this.onBuyIrrigationSprinkler,
                           "clickOnly":true
                        });
                     }
                  }
               }
               for each(tmpObject in plowItems)
               {
                  this.onGetPlowItemsAddObjectToItemsArray(items,tmpObject,terrainAssetTag,terrainCodes,rowIndex,colIndex);
                  rowIndex++;
               }
            }
            terrainCodes = Global.farmGameSettingsManager.convertArrayTerrainNamesToCodes(defaultTerrainNames);
            colIndex = 0;
            defaultPlowItem = {
               "text":ZLocUtils.t("FarmGame","Button_Plow"),
               "icon":EmbeddedArt["hud_act_plow"],
               "onClick":this.onPlow
            };
            this.onGetPlowItemsAddObjectToItemsArray(items,defaultPlowItem,defaultTerrainAssetTag,terrainCodes,rowIndex,colIndex);
         }
         return items;
      }
      
      private function onGetPlowItemsAddObjectToItemsArray(items:Array, itemObject:Object, terrainAssetTag:String, terrainCodes:Array, rowIndex:int, colIndex:int) : Object
      {
         if(itemObject != null)
         {
            if(items[rowIndex] == null)
            {
               items[rowIndex] = new Array();
            }
            itemObject.terrainAssetTag = terrainAssetTag;
            itemObject.terrainCodes = terrainCodes;
            itemObject.passItemDataToCallback = true;
            items[rowIndex][colIndex] = itemObject;
         }
         return null;
      }
      
      protected function onTractor(item:Object) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         CraftingUI.fuelForGoodsToaster();
         var equipment:Tractor = Global.world.getEquipment(Tractor,item.terrainCodes) as Tractor;
         if(equipment == null)
         {
            equipment = Global.world.getEquipment(RotatableTractor,item.terrainCodes) as Tractor;
         }
         if(TurboPPHManager.getInstance().turboSelected && equipment.hasPlowableTerrain())
         {
            Global.world.addGameMode(new GMTractorPlowAll(equipment),true);
         }
         else
         {
            Global.world.addGameMode(new GMTractorPlow(equipment),true);
         }
      }
      
      protected function onPlotRemover(item:Object) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         CraftingUI.fuelForGoodsToaster();
         var equipment:PlotRemover = Global.world.getEquipment(PlotRemover,item.terrainCodes) as PlotRemover;
         if(equipment == null)
         {
            equipment = Global.world.getEquipment(RotatablePlotRemover,item.terrainCodes) as PlotRemover;
         }
         Global.world.addGameMode(new GMPlotRemover(equipment),true);
      }
      
      protected function onBuyPlotRemover(item:Object) : void
      {
         var totPlotRemover:Array = null;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var availablePlotRemovers:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("PlotRemover");
         var rotPlotRemover:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("RotatablePlotRemover");
         if(rotPlotRemover != null && rotPlotRemover.length > 0 && Global.worldManager.currentWorldType == "twenties")
         {
            totPlotRemover = rotPlotRemover.concat(availablePlotRemovers);
         }
         else
         {
            totPlotRemover = availablePlotRemovers.concat(rotPlotRemover);
         }
         totPlotRemover = this.filterItemArrayByTerrainCode(totPlotRemover,item.terrainCodes);
         UI.displayMiniMarketDialog(totPlotRemover,"actionMenuTractorBuy","vehicle");
      }
      
      protected function onBuyTractor(item:Object) : void
      {
         var totTractors:Array = null;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var availableTractors:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("Tractor");
         var rotTractors:Array = Global.farmGameSettingsManager.getFarmItemNamesByClassName("RotatableTractor");
         if(rotTractors != null && rotTractors.length > 0 && Global.worldManager.currentWorldType == "twenties")
         {
            totTractors = rotTractors.concat(availableTractors);
         }
         else
         {
            totTractors = availableTractors.concat(rotTractors);
         }
         totTractors = this.filterItemArrayByTerrainCode(totTractors,item.terrainCodes);
         UI.displayMiniMarketDialog(totTractors,"actionMenuTractorBuy","vehicle");
      }
      
      protected function onPlow(item:Object = null) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         Global.world.addGameMode(new GMMultiPlow(),true);
         dispatchEvent(new ActionMenuEvent(ActionMenuEvent.ONPLOW));
         PetManager.getInstance().resetRescuePet();
      }
      
      protected function onMove(event:Event = null) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         this.showMoveToolFirstUsePopup();
         FarmStatsManager.count("movetool","movetool_users");
         Global.world.addGameMode(new GMDecoMove(),true);
      }
      
      public function onDesignMode(event:Event = null) : void
      {
         DecoratorModeManager.instance.startDecoMode();
      }
      
      protected function showMoveToolFirstUsePopup() : void
      {
         var moveToolFirstUsePopup:String = "MoveToolFirstUsePopup";
         if(!Global.player.getSeenFlag(moveToolFirstUsePopup))
         {
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","MoveToolFirstUse"),GenericPopup.TYPE_OK),true,"MoveToolFirstUsePopup",true);
            Global.player.setSeenFlag(moveToolFirstUsePopup);
         }
      }
      
      protected function showDeleteToolFirstUsePopup() : void
      {
         var deleteToolFirstUsePopup:String = "DeleteToolFirstUsePopup";
         if(!Global.player.getSeenFlag(deleteToolFirstUsePopup))
         {
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","DeleteToolFirstUse"),GenericPopup.TYPE_OK),true,"DeleteToolFirstUsePopup",true);
            Global.player.setSeenFlag(deleteToolFirstUsePopup);
         }
      }
      
      protected function onPlowRollover(event:Event = null) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.highlight(this.m_plow);
         }
         else
         {
            this.m_plow.toggle();
            this.m_walk.untoggle();
            this.m_topRight.untoggle();
            this.m_gifts.untoggle();
            this.m_bottomLeft.untoggle();
         }
      }
      
      protected function onStorage(e:MouseEvent) : void
      {
         if(!Global.worldManager.isVisiting())
         {
            this.onGifts(e);
         }
      }
      
      protected function onStorageRollover(e:MouseEvent) : void
      {
         var giftCount:int = 0;
         if(this.m_displayButtonMenusOnRollover)
         {
            if(!Global.worldManager.isVisiting())
            {
               FarmStatsManager.sample(100,"Storage","accessing_goods","general_HUD_icon");
               if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
               {
                  giftCount = int(Global.player.getGifts().length);
               }
               else
               {
                  giftCount = Global.player.getGiftCount();
               }
               this.m_giftsCount.visible = giftCount > 0;
               if(giftCount > this.GIFT_COUNT_PLUS_LIMIT)
               {
                  this.m_giftsCountText.text = this.EXCEED_PLUS_SIGN;
               }
               else
               {
                  this.m_giftsCountText.text = String(giftCount);
               }
               this.m_giftsDisplaying = true;
            }
         }
      }
      
      private function onGetTopRightItems() : Array
      {
         var i:int = 0;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var items:Array = [];
         if(!this.m_locked)
         {
            items.push({
               "text":ZLocUtils.t("FarmGame","Button_Clear"),
               "icon":EmbeddedArt.hud_act_clear,
               "onClick":this.onClearMultiMenu
            });
            if(this.m_tempTopRightItems != null)
            {
               for(i = 0; i < this.m_tempTopRightItems.length; i++)
               {
                  items.push(this.m_tempTopRightItems[i]);
               }
            }
            items.sort(this.orderByLocation);
         }
         return items;
      }
      
      public function addTempTopRightItem(newItem:Object) : void
      {
         this.m_tempTopRightItems.push(newItem);
         this.m_tempTopRightItems.sort(this.orderByLocation);
         this.m_topRight.updateItems(true);
      }
      
      private function orderByLocation(iconA:Object, iconB:Object) : int
      {
         var iconALocation:Number = 0;
         var iconBLocation:Number = 0;
         if(iconA.hasOwnProperty("location"))
         {
            iconALocation = Number(iconA.location);
         }
         if(iconB.hasOwnProperty("location"))
         {
            iconBLocation = Number(iconB.location);
         }
         if(iconALocation < iconBLocation)
         {
            return -1;
         }
         if(iconALocation > iconBLocation)
         {
            return 1;
         }
         return 0;
      }
      
      public function clearTempTopRightItems() : void
      {
         this.m_tempTopRightItems = [];
         this.m_topRight.updateItems();
      }
      
      private function onClearMultiMenu() : void
      {
         var gmClear:GMClear = null;
         var levelLock:int = Global.farmGameSettingsManager.getInt("sellLockLevel",this.DEFAULT_SELL_LOCK_LEVEL);
         if(Global.player.level >= levelLock)
         {
            this.m_walk.untoggle();
            gmClear = new GMClear();
            gmClear.killDeleteConfirm();
            Global.setQuickDelete(false);
            this.showDeleteToolFirstUsePopup();
            Global.world.addGameMode(gmClear);
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("FarmGame","ToolUnlockFailure",{"level":levelLock}),GenericPopup.TYPE_OK);
         }
         FarmStatsManager.count("TravelButton","Recycle","Click");
      }
      
      private function onTopRightRollover(e:MouseEvent) : void
      {
         this.highlight(this.m_topRight);
      }
      
      private function onGetBottomLeftItems() : Array
      {
         var index:* = 0;
         var buttonTextAndTooltip:String = null;
         var functionName:String = null;
         var multiColumnItems:Array = null;
         var numCols:int = 0;
         var numRows:int = 0;
         var rowIndex:int = 0;
         var colIndex:int = 0;
         var itemIndex:int = 0;
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         var items:Array = [];
         var latestEliteHorses:Array = [];
         if(!this.m_locked)
         {
            items.push({
               "text":ZLocUtils.t("FarmGame","Button_Mastery"),
               "icon":EmbeddedArt.hud_act_mastery,
               "onClick":this.onMastery,
               "isMastery":true
            });
            if(Global.player.level >= Global.farmGameSettingsManager.getAttribute("collectionStartLevel",15))
            {
               items.push({
                  "text":ZLocUtils.t("FarmGame","Button_Collections"),
                  "icon":EmbeddedArt.hud_collections,
                  "onClick":this.onCollections
               });
            }
            items.push({
               "text":ZLocUtils.t("FarmGame","Button_Achievements"),
               "icon":EmbeddedArt.hud_achievements,
               "onClick":this.onAchievements
            });
            if(Global.player.level >= 15 && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_DRAGON_BREEDING) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
            {
               items.push({
                  "text":ZLocUtils.t("FarmGame","Button_DragonEyrie"),
                  "icon":EmbeddedArt.hud_dragon_breeding,
                  "onClick":this.onDragonBreeding
               });
            }
            else if(ItemContestManager.inMainExperiment())
            {
               items.push({
                  "text":ZLocUtils.t("FarmGame","Button_Contests"),
                  "icon":EmbeddedArt.hud_item_contests,
                  "onClick":this.onItemContests
               });
            }
            if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_DAIRY_CRAFTING))
            {
               items.push({
                  "text":ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_dairyCraft"),
                  "icon":EmbeddedArt.hud_dairyCrafting,
                  "onClick":this.onDairyCrafting
               });
               FeatureMessagingManager.getInstance().registerFeatureInitialized(FeatureCraftingSystem.SYSTEM_DAIRY_CRAFTING,this.onDairyCrafting);
            }
            if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_YARN_BARN))
            {
               items.push({
                  "text":ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_yarnbarn"),
                  "icon":EmbeddedArt.hud_yarnbarn,
                  "onClick":this.onYarnBarn
               });
               FeatureMessagingManager.getInstance().registerFeatureInitialized(FeatureCraftingSystem.SYSTEM_YARN_BARN,this.onYarnBarn);
            }
            if(CraftingManager.shouldShowCraftingIconForWorld(Global.worldManager.currentWorldType))
            {
               items.push({
                  "text":ZLocUtils.t("FarmGame","Button_Craftshop"),
                  "icon":EmbeddedArt.hud_newCraftShop,
                  "onClick":CraftingManager.surfaceNewCraftShop
               });
            }
            if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.SYSTEM_HORSE_CRAFTING))
            {
               items.push({
                  "text":ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"ActionMenu_horseCrafting"),
                  "icon":EmbeddedArt.hud_horseCrafting,
                  "onClick":this.onHorseCrafting
               });
               FeatureMessagingManager.getInstance().registerFeatureInitialized(FeatureCraftingSystem.SYSTEM_HORSE_CRAFTING,this.onHorseCrafting);
            }
            if(ItemMembershipManager.isInItemMembershipExperiment())
            {
               buttonTextAndTooltip = ZLocUtils.t("FarmGame","Button_ItemMembership");
               items.push({
                  "text":buttonTextAndTooltip,
                  "toolTip":buttonTextAndTooltip,
                  "icon":EmbeddedArt.hud_item_membership,
                  "onClick":ItemMembershipManager.onActionMenuIconClicked
               });
            }
            for(index = 0; index < FeatureCraftingSystem.ALL_ELITEHORSES.length; index++)
            {
               if(FeatureCraftingManager.instance.arePrerequisitesMet(FeatureCraftingSystem.ALL_ELITEHORSES[index][0]))
               {
                  functionName = FeatureCraftingSystem.ALL_ELITEHORSES[index][3];
                  latestEliteHorses.push({
                     "text":ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,FeatureCraftingSystem.ALL_ELITEHORSES[index][1]),
                     "icon":FeatureCraftingSystem.ALL_ELITEHORSES[index][2],
                     "onClick":this[functionName]
                  });
                  FeatureMessagingManager.getInstance().registerFeatureInitialized(FeatureCraftingSystem.ALL_ELITEHORSES[index][0],this[functionName]);
               }
            }
            for(index = FeatureCraftingSystem.ACTIONMENU_ELITEHORSES_LIMIT; index > 0; index--)
            {
               if(latestEliteHorses[index - 1])
               {
                  items.push(latestEliteHorses[index - 1]);
               }
            }
         }
         if(items.length > ActionMultiButton.MAX_ROWS)
         {
            multiColumnItems = [];
            numCols = 2;
            numRows = Math.ceil(items.length / numCols);
            for(rowIndex = 0; rowIndex < numRows; rowIndex++)
            {
               for(colIndex = 0; colIndex < numCols; colIndex++)
               {
                  itemIndex = rowIndex * numCols + colIndex;
                  if(itemIndex < items.length)
                  {
                     if(!multiColumnItems[rowIndex])
                     {
                        multiColumnItems[rowIndex] = new Array();
                     }
                     multiColumnItems[rowIndex][colIndex] = items[itemIndex];
                  }
               }
            }
            items = multiColumnItems;
         }
         return items;
      }
      
      private function onAchievementsClick(event:Event = null) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.untoggleAll();
         }
         this.onAchievements();
      }
      
      private function onBottomLeftRollover(event:Event = null) : void
      {
         this.highlight(this.m_bottomLeft);
      }
      
      private function onAchievements() : void
      {
         this.untoggleAll();
         UI.displayPopup(new Achievements(true));
         this.m_bottomLeft.untoggle();
         FarmStatsManager.count("EhButton","Achievements","Click");
      }
      
      private function onLeaderboards() : void
      {
         this.untoggleAll();
         this.m_bottomLeft.untoggle();
         LeaderboardManager.displayLeaderboardWindow();
         FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"clicks","toolbar_icon");
      }
      
      private function onItemContests() : void
      {
         this.untoggleAll();
         if(this.m_notice != null)
         {
            this.m_notice.visible = false;
            this.m_bottomLeft.parent.removeChild(this.m_notice);
            this.m_notice = null;
         }
         var itemContestManager:ItemContestManager = ItemContestManager.getInstance();
         FarmStatsManager.count(itemContestManager.getCurrentContestName(),"click_action_menu");
         itemContestManager.displayDialog();
      }
      
      private function onDragonBreeding() : void
      {
         this.untoggleAll();
         DragonBreedingManager.getInstance(this.DRAGON_EYRIE).openDragonBreedingUI();
         FarmStatsManager.count("EhButton","DragonEyrie","Click");
      }
      
      private function onDairyCrafting() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_DAIRY_CRAFTING;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onHorseCrafting() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_HORSE_CRAFTING;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count("EhButton","EliteHorses","Click");
      }
      
      private function onHollybrightPark() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_HOLLYBRIGHT_PARK;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onSavannahreserve() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_SAVANNAHRESERVE;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXtr_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XTR_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count("EhButton",systemName,"Click");
      }
      
      private function onXwi_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XWI_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count("EhButton",systemName,"Click");
      }
      
      private function onXin_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XIN_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count("EhButton",systemName,"Click");
      }
      
      private function onXjp_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName,WorldsConstants.WORLD_ID_JAPAN);
         FarmStatsManager.count("EhButton",systemName,"Click");
      }
      
      private function onXjp_elitehorses_ms() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XJP_ELITEHORSES_MS;
         FeatureCraftingManager.instance.showUI(systemName,WorldsConstants.WORLD_ID_JAPAN);
         FarmStatsManager.count("EhButton",systemName,"Click");
      }
      
      private function onXjm_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XJM_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count("EhButton",systemName,"Click");
      }
      
      private function onXmo_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XMO_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXbo_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XBO_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
         LimboInnovationManager.getInstance().initEventListener();
      }
      
      private function onXch_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XCH_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXhh_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XHH_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXti_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XTI_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXdw_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XDW_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXfe_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XFE_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXha_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XHA_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXfw_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XFW_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXty_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XTY_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXdv_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XDV_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXcb_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XCB_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXru_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XRU_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXnf_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XNF_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXis_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XIS_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXhx_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XHX_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXwx_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XWX_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXca_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XCA_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXbl_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XBL_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXrt_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XRT_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXsu_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XSU_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXcl_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XCL_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXid_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XID_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXhf_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XHF_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXws_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XWS_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXfs_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XFS_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXmt_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XMT_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXbb_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XBB_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXdm_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XDM_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXcd_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XCD_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXah_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XAH_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXpu_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XPU_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXyt_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XYT_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXbr_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XBR_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onXuw_elitehorses() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_XUW_ELITEHORSES;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count(systemName,"click_action_menu");
      }
      
      private function onYarnBarn() : void
      {
         this.untoggleAll();
         var systemName:String = FeatureCraftingSystem.SYSTEM_YARN_BARN;
         FeatureCraftingManager.instance.showUI(systemName);
         FarmStatsManager.count("EhButton","YarnBarn","Click");
      }
      
      private function onMastery() : void
      {
         this.untoggleAll();
         UI.displayPopup(new MasteryWindow());
         FarmStatsManager.count("EhButton","Mastery","Click");
      }
      
      private function onCollections() : void
      {
         this.untoggleAll();
         UI.displayPopup(new CollectionsWindow());
         FarmStatsManager.count("EhButton","Collections","Click");
      }
      
      public function onMarket(e:MouseEvent) : void
      {
         var type:String = null;
         var subType:String = null;
         var subSubType:String = null;
         var sortBy:String = null;
         var sortDirection:String = null;
         var page:int = 0;
         this.untoggleAll();
         this.setDefaultGameMode();
         if(!this.m_locked && Global.player.postInitFinished)
         {
            type = MarketWindow.previousType;
            subType = MarketWindow.previousSubType;
            subSubType = MarketWindow.previousSubSubType;
            sortBy = MarketWindow.previousSortBy;
            sortDirection = MarketWindow.previousSortDirection;
            page = MarketWindow.previousPage;
            if(this.m_marketIndicator != null)
            {
               type = MarketIndicatorConfig.getInstance().marketCategory;
               subType = MarketIndicatorConfig.getInstance().marketSubcategory;
               this.removeMarketIndicatorArrow();
            }
            MarketStatsManager.countOpenMarketFromToolbox();
            FarmStatsManager.count("MarketButton","Market","Click");
            UI.displayMarketDialog("actionMenu",type,null,subType,null,subSubType,sortBy,sortDirection,page);
         }
      }
      
      private function onMarketRollover(e:MouseEvent) : void
      {
         if(!this.m_displayButtonMenusOnRollover)
         {
            this.unHighlightAll();
         }
         else
         {
            this.untoggleAll();
         }
      }
      
      public function onGifts(e:MouseEvent = null) : void
      {
         var giftCount:int = 0;
         this.untoggleAll();
         if(!UI.areGiftsLocked())
         {
            UI.displayGiftBoxWindow(true,"",true);
            if(!Global.worldManager.isVisiting())
            {
               if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
               {
                  giftCount = int(Global.player.getGifts().length);
               }
               else
               {
                  giftCount = Global.player.getGiftCount();
               }
               if(giftCount > this.GIFT_COUNT_PLUS_LIMIT)
               {
                  this.m_giftsCountText.text = this.EXCEED_PLUS_SIGN;
               }
               else
               {
                  this.m_giftsCountText.text = String(giftCount);
               }
               this.m_giftsCount.visible = giftCount > 0;
            }
            this.m_giftsDisplaying = true;
         }
         FarmStatsManager.count("GiftsButton","Gifts","Click");
      }
      
      public function onInventory(e:MouseEvent = null) : void
      {
         var type:String = null;
         this.untoggleAll();
         if(Global.player.getInventoryCapacity() > 0)
         {
            type = "inventory";
            if(Global.player.upgradeStatus.isActive)
            {
               type = "upgrade";
            }
            UI.displayInventoryDialog(type);
            FarmStatsManager.sample(100,"Storage","accessing_goods","storage_HUD_icon");
         }
         else
         {
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","NoInventoryCapacity"),GenericPopup.TYPE_YESNO,this.openMarket));
            FarmStatsManager.sample(100,"Storage","want_more_storage");
         }
         if(!Global.worldManager.isVisiting())
         {
            this.m_giftsCountText.text = Global.player.getInventoryUsage().toString();
            this.m_giftsCount.visible = Global.player.getInventoryUsage() > 0;
         }
         this.m_gifts.untoggle();
         this.m_giftsDisplaying = false;
         FarmStatsManager.count("GiftsButton","Storage","Click");
      }
      
      private function onSearch(e:MouseEvent = null) : void
      {
         this.untoggleAll();
         ItemFinderWindow.launchItemFinder();
         this.m_giftsCount.visible = false;
         this.m_gifts.untoggle();
         this.m_giftsDisplaying = false;
         FarmStatsManager.count("GiftsButton","Search","Click");
      }
      
      private function openMarket(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            UI.displayMarketDialog("ActionMenu","building",null,"storage");
         }
      }
      
      public function get initialized() : Boolean
      {
         return this.m_initialized;
      }
      
      public function get locked() : Boolean
      {
         return this.m_locked;
      }
      
      public function set locked(val:Boolean) : void
      {
         this.m_locked = val;
      }
   }
}

