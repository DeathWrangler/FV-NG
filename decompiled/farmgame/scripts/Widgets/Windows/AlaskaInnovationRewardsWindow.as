package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class AlaskaInnovationRewardsWindow extends FarmWindow
   {
      
      private var m_featureName:String = null;
      
      private var m_subFeatureName:String = null;
      
      private var m_float1:FarmAnimatedButton = null;
      
      private var m_float2:FarmAnimatedButton = null;
      
      private var m_float3:FarmAnimatedButton = null;
      
      private var m_float4:FarmAnimatedButton = null;
      
      private const TEXT_FLOAT1_NAME:String = "Saint Bernard Doghouse";
      
      private const TEXT_FLOAT2_NAME:String = "Poodle Doghouse";
      
      private const TEXT_FLOAT3_NAME:String = "Alaskan Malamute Doghouse";
      
      private const TEXT_FLOAT4_NAME:String = "Eskimo Dog Doghouse";
      
      private var m_ownerwindow:DreamWorldInnovationWindow = null;
      
      private var m_textPrefix:String = this.m_subFeatureName ? this.m_featureName + "_" + this.m_subFeatureName : this.m_featureName;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_bgLoader:ImageLoader = null;
      
      public function AlaskaInnovationRewardsWindow(dialogAsset:String, featureName:String = null, subFeatureName:String = null, window:DreamWorldInnovationWindow = null, dialogBackground:String = null)
      {
         this.m_featureName = featureName;
         this.m_ownerwindow = window;
         this.m_subFeatureName = subFeatureName;
         super(dialogAsset);
         if(dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         if(Boolean(m_window) && Boolean(m_window.mainWindow))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow.title_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_textPrefix + "_title")));
            }
            if(m_window.mainWindow.body_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_textPrefix + "_body2")));
            }
            if(m_window.mainWindow.body2_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.body2_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_textPrefix + "_body")));
            }
            if(m_window.mainWindow.generic_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.generic_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_textPrefix + "_btnText"),this.onButtonClick));
            }
            if(m_window.mainWindow.bonus_bt)
            {
               addWidget(new FarmAnimatedButton(m_window.mainWindow.bonus_bt));
            }
            if(m_window.mainWindow.reward1_mc)
            {
               addWidget(this.m_float1 = new FarmAnimatedButton(m_window.mainWindow.reward1_mc));
               this.m_float1.attachTooltip(new FarmTextTooltip(this.TEXT_FLOAT1_NAME));
            }
            if(m_window.mainWindow.reward2_mc)
            {
               addWidget(this.m_float2 = new FarmAnimatedButton(m_window.mainWindow.reward2_mc));
               this.m_float2.attachTooltip(new FarmTextTooltip(this.TEXT_FLOAT2_NAME));
            }
            if(m_window.mainWindow.reward3_mc)
            {
               addWidget(this.m_float3 = new FarmAnimatedButton(m_window.mainWindow.reward3_mc));
               this.m_float3.attachTooltip(new FarmTextTooltip(this.TEXT_FLOAT3_NAME));
            }
            if(m_window.mainWindow.reward4_mc)
            {
               addWidget(this.m_float4 = new FarmAnimatedButton(m_window.mainWindow.reward4_mc));
               this.m_float4.attachTooltip(new FarmTextTooltip(this.TEXT_FLOAT4_NAME));
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
         }
      }
      
      private function onButtonClick(event:MouseEvent) : void
      {
         if(this.m_ownerwindow != null)
         {
            this.m_ownerwindow.untintWindow();
            this.m_ownerwindow.enableInput = true;
         }
         close();
      }
      
      override protected function release() : void
      {
         this.m_featureName = null;
         this.m_subFeatureName = null;
         m_window = null;
         super.release();
      }
   }
}

