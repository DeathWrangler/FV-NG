package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.MystreeNurseryManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class MystreeNurserySunshineBuyWindow extends FarmWindow
   {
      
      private static const X:String = "x";
      
      private static const PKG_SUNSHINEBUCKET1:String = "pkg_sunshinebucket_10";
      
      private static const PKG_SUNSHINEBUCKET2:String = "pkg_sunshinebucket_20";
      
      private static const PKG_SUNSHINEBUCKET3:String = "pkg_sunshinebucket_30";
      
      private var m_sunshineCount0:ZwTextField;
      
      private var m_sunshineCount1:ZwTextField;
      
      private var m_sunshineCount2:ZwTextField;
      
      private var m_buySunshineBucket0:FarmAnimatedCashButton;
      
      private var m_buySunshineBucket1:FarmAnimatedCashButton;
      
      private var m_buySunshineBucket2:FarmAnimatedCashButton;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      public function MystreeNurserySunshineBuyWindow()
      {
         super(MystreeNurseryManager.OUT_OF_SB_BUY_ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("cashbuy0_bt"))
         {
            addWidget(this.m_buySunshineBucket0 = new FarmAnimatedCashButton(m_window.cashbuy0_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonWindowText"),MystreeNurseryManager.SUNSHINEBUCKET_SET0_COST.toString(),this.onSunshine10BuyClick),false);
            this.m_buySunshineBucket0.visible = true;
         }
         if(m_window.hasOwnProperty("cashbuy1_bt"))
         {
            addWidget(this.m_buySunshineBucket1 = new FarmAnimatedCashButton(m_window.cashbuy1_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonWindowText"),MystreeNurseryManager.SUNSHINEBUCKET_SET1_COST.toString(),this.onSunshine20BuyClick),false);
            this.m_buySunshineBucket1.visible = true;
         }
         if(m_window.hasOwnProperty("cashbuy2_bt"))
         {
            addWidget(this.m_buySunshineBucket2 = new FarmAnimatedCashButton(m_window.cashbuy2_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeSunshineBuyButtonWindowText"),MystreeNurseryManager.SUNSHINEBUCKET_SET2_COST.toString(),this.onSunshine30BuyClick),false);
            this.m_buySunshineBucket2.visible = true;
         }
         if(m_window.hasOwnProperty("count_tf_0"))
         {
            addWidget(this.m_sunshineCount0 = new ZwTextField(m_window.count_tf_0,X + MystreeNurseryManager.SUNSHINEBUCKET_SET0.toString()),true);
            this.m_sunshineCount0.visible = true;
         }
         if(m_window.hasOwnProperty("count_tf_1"))
         {
            addWidget(this.m_sunshineCount1 = new ZwTextField(m_window.count_tf_1,X + MystreeNurseryManager.SUNSHINEBUCKET_SET1.toString()),true);
            this.m_sunshineCount1.visible = true;
         }
         if(m_window.hasOwnProperty("count_tf_2"))
         {
            addWidget(this.m_sunshineCount2 = new ZwTextField(m_window.count_tf_2,X + MystreeNurseryManager.SUNSHINEBUCKET_SET2.toString()),true);
            this.m_sunshineCount2.visible = true;
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeNurserySunshineBuyWindow_title")),true);
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MystreeNurserySunshineBuyWindow_body")),true);
         }
      }
      
      private function onSunshine10BuyClick(buyInstance:int) : void
      {
         MystreeNurseryManager.getInstance().buySunshineBuckets(PKG_SUNSHINEBUCKET1);
         close();
      }
      
      private function onSunshine20BuyClick(buyInstance:int) : void
      {
         MystreeNurseryManager.getInstance().buySunshineBuckets(PKG_SUNSHINEBUCKET2);
         close();
      }
      
      private function onSunshine30BuyClick(buyInstance:int) : void
      {
         MystreeNurseryManager.getInstance().buySunshineBuckets(PKG_SUNSHINEBUCKET3);
         close();
      }
      
      override protected function release() : void
      {
         this.m_sunshineCount0 = null;
         this.m_sunshineCount1 = null;
         this.m_sunshineCount2 = null;
         this.m_buySunshineBucket0 = null;
         this.m_buySunshineBucket1 = null;
         this.m_buySunshineBucket2 = null;
         super.release();
      }
   }
}

