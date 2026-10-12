package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Managers.OrderBoard.CasablancaInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class CongratsForNewCaribbeanInovationWindow extends FarmWindow
   {
      
      private var m_marketItems:Array = new Array();
      
      private var m_featureName:String = null;
      
      private var m_subFeatureName:String = null;
      
      private var m_callback:Function = null;
      
      private var m_textPrefix:String = this.m_subFeatureName ? this.m_featureName + "_" + this.m_subFeatureName : this.m_featureName;
      
      private var m_ownerWindow:CarribeanInnovationWindow;
      
      private var m_bonusItemName:String = null;
      
      private var m_rewardItem:FarmItem;
      
      public function CongratsForNewCaribbeanInovationWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem, callback:Function = null, params:Object = null, bonusItemName:String = null)
      {
         this.m_featureName = featureName;
         this.m_bonusItemName = bonusItemName;
         this.m_rewardItem = rewardItem;
         super(dialogAsset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         if(Boolean(m_window) && Boolean(m_window.mainWindow))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow.title_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.title_tf,"Adele Bistro!"));
            }
            if(m_window.mainWindow.body_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.body_tf,"Grow your business into a popular Bistro at 1000 Acclaim and get some cool rewards!"));
            }
            if(m_window.mainWindow.body2_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.body2_tf,"Harvest the bistro everyday for consumables till 3rd March, 2019"));
            }
            if(m_window.mainWindow.bonus_mc)
            {
               if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_CASABLANCA))
               {
                  m_window.mainWindow.bonus_mc.visible = true;
               }
               else
               {
                  m_window.mainWindow.bonus_mc.visible = false;
               }
            }
            if(m_window.mainWindow.generic_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.generic_bt,"Awesome",this.closePopup));
            }
         }
      }
      
      public function closePopup(event:MouseEvent = null) : void
      {
         super.close();
         untintWindow();
         var featureName:String = this.m_featureName.substring(0,this.m_featureName.length - 13);
         CasablancaInnovationManager.getInstance(featureName).showMainUI();
      }
   }
}

