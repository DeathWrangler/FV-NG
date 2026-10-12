package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Managers.AFInnovationManager;
   import Managers.FeatureOptionsInventoryManager;
   import Widgets.Frames.AFInnovationRedeemFrame;
   import flash.display.MovieClip;
   import flash.utils.Timer;
   
   public class AFInnovationRedeemWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const COUNT_TF:String = "count_tf";
      
      private const NAME_TF:String = "name_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const INVENTORY_MC:String = "inventory_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private var m_inventory_mc:MovieClip;
      
      private var m_slots:AFInnovationRedeemFrame;
      
      private var m_featureName:String = null;
      
      private var m_timer:Timer;
      
      public function AFInnovationRedeemWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_Title");
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            m_window[this.BODY_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_RedeemWindow_BodyText");
         }
         if(m_window.hasOwnProperty(this.SLOTS_MC))
         {
            this.m_slots = new AFInnovationRedeemFrame(m_window[this.SLOTS_MC],this.m_featureName,this);
            this.m_slots.visible = true;
            addWidget(this.m_slots,true);
         }
         if(m_window.hasOwnProperty(this.INVENTORY_MC))
         {
            this.m_inventory_mc = m_window[this.INVENTORY_MC] as MovieClip;
            this.m_inventory_mc.visible = true;
            this.m_inventory_mc[this.COUNT_TF].text = "x" + FeatureOptionsInventoryManager.getInstance().getCount(AFInnovationManager.getInstance().CurrencyCode.toString());
            this.m_inventory_mc[this.NAME_TF].text = Global.farmGameSettingsManager.getFarmItemByCode(AFInnovationManager.getInstance().CurrencyCode).friendlyTitle;
         }
      }
      
      override public function refreshWindow() : void
      {
         this.m_slots.refresh();
         this.m_inventory_mc[this.COUNT_TF].text = "x" + FeatureOptionsInventoryManager.getInstance().getCount(AFInnovationManager.getInstance().CurrencyCode.toString());
      }
      
      override public function close() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
         super.close();
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("AFInnovation_feature_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            AFInnovationManager.getInstance().showMainUI();
         }
      }
   }
}

