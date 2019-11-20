//function processFormData() {
  
 // const locationElement = document.getElementById("location");
 // const nalocation = nameElement.value;
  
  //alert("您輸入的地址是 \n" + location );
//}

const submitBtn = document.querySelector('[data-action="submit"]');
submitBtn.addEventListener("click", processFormData);

function processFormData(e) {
  // 方法 1-1：getElementById - 從 input
  // const nameElement = document.getElementById("name");
  // const name = nameElement.value;
  // const emailElement = document.getElementById("email");
  // const email = emailElement.value;

  // 方法 1-2：getElementById - 從 form
  // const formElement = document.getElementById("form");
  // const name = formElement[0].value;
  // const email = formElement[1].value;

 

  // 方法 2：getElementsByTagName
  
  // const inputElement = document.getElementsByTagName('input');
  // const name = inputElement[0].value;
  // const email = inputElement[1].value;

  // 方法 3：getElementsByName
  // const nameElement = document.getElementsByName('name');
  // const name = nameElement[0].value;
  // const emailElement = document.getElementsByName('email');
  // const email = emailElement[0].value;

  // 方法 4：取得表單元素
  //取得 name 屬性為 form 的表單
  const form = document.forms['form'];
  //取 elements 集合中 name 屬性為 name 的值
  const loaction = form.elements.loaction.value;


  alert("您輸入的地址是\n" + loaction);
}