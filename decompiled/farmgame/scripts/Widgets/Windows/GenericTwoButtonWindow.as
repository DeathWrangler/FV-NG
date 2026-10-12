package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class GenericTwoButtonWindow extends FarmWindow
   {
      
      private static const CLASS_NAME:String = "GenericTwoButtonWindow";
      
      private var m_featureName:String;
      
      private var m_callback1:Function;
      
      private var m_callback2:Function;
      
      private var m_zlocParams:Object;
      
      public function GenericTwoButtonWindow(assetPath:String, featureName:String, callback1:Function, callback2:Function = null, zLocParams:Object = null)
      {
         super(assetPath);
         this.m_featureName = featureName;
         this.m_callback1 = callback1;
         this.m_callback2 = callback2;
         this.m_zlocParams = zLocParams;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window)
         {
            if(m_window.title_tf)
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,CLASS_NAME + "_" + this.m_featureName + "_title",this.m_zlocParams)));
            }
            if(m_window.body_tf)
            {
               addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,CLASS_NAME + "_" + this.m_featureName + "_body",this.m_zlocParams)));
            }
            if(m_window.accept_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,CLASS_NAME + "_" + this.m_featureName + "_buttonText1"),this.onButton1Clicked));
            }
            if(m_window.cancel_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,CLASS_NAME + "_" + this.m_featureName + "_buttonText2"),this.onButton2Clicked));
            }
            this.count(StatsTrackingConstants.IMPRESSIONS);
         }
      }
      
      private function onButton1Clicked(event:MouseEvent) : void
      {
         this.count("button_1_click");
         this.m_callback1();
         close();
      }
      
      private function onButton2Clicked(event:MouseEvent) : void
      {
         this.count("button_1_click");
         if(this.m_callback2 != null)
         {
            this.m_callback2();
         }
         close();
      }
      
      private function count(phylum:String) : void
      {
         StatsManager.count(CLASS_NAME,this.m_featureName,phylum);
      }
      
      override protected function release() : void
      {
         this.m_featureName = null;
         this.m_callback1 = null;
         this.m_callback2 = null;
         this.m_zlocParams = null;
         super.release();
      }
   }
}

