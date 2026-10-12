package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.MouseEvent;
   
   public class GenericSingleButtonWindow extends FarmWindow
   {
      
      private var m_featureName:String = null;
      
      private var m_subFeatureName:String = null;
      
      private var m_float1:FarmAnimatedButton = null;
      
      private var m_float2:FarmAnimatedButton = null;
      
      private var m_float3:FarmAnimatedButton = null;
      
      private var m_float4:FarmAnimatedButton = null;
      
      private const TEXT_FLOAT1_NAME:String = "Royal Rio Elephants Float";
      
      private const TEXT_FLOAT2_NAME:String = "Rio Carousel Float";
      
      private const TEXT_FLOAT3_NAME:String = "Rio Bull Float";
      
      private const TEXT_FLOAT4_NAME:String = "Rio Party Horse Float";
      
      private var m_callback:Function = null;
      
      private var m_textPrefix:String = this.m_subFeatureName ? this.m_featureName + "_" + this.m_subFeatureName : this.m_featureName;
      
      public function GenericSingleButtonWindow(dialogAsset:String, featureName:String = null, subFeatureName:String = null, callBack:Function = null)
      {
         this.m_featureName = featureName;
         this.m_callback = callBack;
         this.m_subFeatureName = subFeatureName;
         super(dialogAsset);
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
            if(m_window.mainWindow.description_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.description_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_textPrefix + "_desc")));
            }
            if(m_window.mainWindow.generic_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.generic_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_textPrefix + "_btnText"),this.onButtonClick));
            }
            if(m_window.mainWindow.bonus_bt)
            {
               addWidget(new FarmAnimatedButton(m_window.mainWindow.bonus_bt));
            }
            if(m_window.mainWindow.float1_mc)
            {
               addWidget(this.m_float1 = new FarmAnimatedButton(m_window.mainWindow.float1_mc));
               this.m_float1.attachTooltip(new FarmTextTooltip(this.TEXT_FLOAT1_NAME));
            }
            if(m_window.mainWindow.float2_mc)
            {
               addWidget(this.m_float2 = new FarmAnimatedButton(m_window.mainWindow.float2_mc));
               this.m_float2.attachTooltip(new FarmTextTooltip(this.TEXT_FLOAT2_NAME));
            }
            if(m_window.mainWindow.float3_mc)
            {
               addWidget(this.m_float3 = new FarmAnimatedButton(m_window.mainWindow.float3_mc));
               this.m_float3.attachTooltip(new FarmTextTooltip(this.TEXT_FLOAT3_NAME));
            }
            if(m_window.mainWindow.float4_mc)
            {
               addWidget(this.m_float4 = new FarmAnimatedButton(m_window.mainWindow.float4_mc));
               this.m_float4.attachTooltip(new FarmTextTooltip(this.TEXT_FLOAT4_NAME));
            }
         }
      }
      
      private function onButtonClick(event:MouseEvent) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback();
         }
         close();
      }
      
      override protected function release() : void
      {
         this.m_featureName = null;
         this.m_subFeatureName = null;
         this.m_callback = null;
         super.release();
      }
   }
}

