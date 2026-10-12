package Classes
{
   public class BeatExpansionTaskDefinition
   {
      
      private var m_name:String;
      
      private var m_imageUrl:String;
      
      private var m_progress:int;
      
      private var m_total:int;
      
      private var m_action:String;
      
      private var m_args:Array;
      
      private var m_purchase:String;
      
      private var m_price:int;
      
      private var m_currency:String;
      
      private var m_butVisible:Boolean;
      
      private var m_rewardUrl:String;
      
      public function BeatExpansionTaskDefinition(name:String, imageUrl:String, progress:int, total:int, action:String, args:Array, rewardUrl:String, purchase:String = null, price:int = 0, currency:String = null, butVisible:Boolean = true)
      {
         super();
         this.m_name = name;
         this.m_imageUrl = imageUrl;
         this.m_progress = progress;
         this.m_total = total;
         this.m_action = action;
         this.m_args = args;
         this.m_rewardUrl = rewardUrl;
         this.m_purchase = purchase;
         this.m_price = price;
         this.m_currency = currency;
         this.m_butVisible = butVisible;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get imageUrl() : String
      {
         return this.m_imageUrl;
      }
      
      public function get progress() : int
      {
         return this.m_progress;
      }
      
      public function set progress(newProgress:int) : void
      {
         this.m_progress = newProgress;
      }
      
      public function get total() : int
      {
         return this.m_total;
      }
      
      public function set total(newTotal:int) : void
      {
         this.m_total = newTotal;
      }
      
      public function get action() : String
      {
         return this.m_action;
      }
      
      public function get args() : Array
      {
         return this.m_args;
      }
      
      public function get rewardUrl() : String
      {
         return this.m_rewardUrl;
      }
      
      public function get price() : int
      {
         return this.m_price;
      }
      
      public function get purchase() : String
      {
         return this.m_purchase;
      }
      
      public function get currency() : String
      {
         return this.m_currency;
      }
      
      public function get butVisible() : Boolean
      {
         return this.m_butVisible;
      }
   }
}

