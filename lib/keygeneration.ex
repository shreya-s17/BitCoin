defmodule KEYGENERATION do
  def generate_rsa() do
    {pem, 0} = System.cmd "openssl", ["genrsa","2048"]
    {:RSAPrivateKey, :'two-prime', n , e, d, _p, _q, _e1, _e2, _c, _other} = pem
    |> :public_key.pem_decode |> List.first |> :public_key.pem_entry_decode
    {e, n, d}
  end
end
